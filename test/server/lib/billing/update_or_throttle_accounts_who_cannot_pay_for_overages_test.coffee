updateOrThrottleAccountsWhoCannotPayForOverages = Cine.server_lib('billing/update_or_throttle_accounts_who_cannot_pay_for_overages')
Account = Cine.server_model("account")
AccountEmailHistory = Cine.server_model("account_email_history")
humanizeBytes = Cine.lib('humanize_bytes')
mailer = Cine.server_lib("mailer")
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')

describe 'updateOrThrottleAccountsWhoCannotPayForOverages', ->
  beforeEach (done)->
    @account = new Account(billingProvider: 'cine.io', plans: ['solo'])
    @account.save done

  describe 'cine.io accounts', ->
    beforeEach (done)->
      @account.billingProvider = 'cine.io'
      @account.save done

    describe 'with a credit card', ->

      beforeEach (done)->
        @account.stripeCustomer.stripeCustomerId = "cus_2ghmxawfvEwXkw"
        @account.stripeCustomer.cards.push stripeCardId: "card_102gkI2AL5avr9E4geO0PpkC"
        @account.save done

      describe '80% of account limit', ->
        beforeEach ->
          @usageStub = sinon.stub(calculateAccountUsage, 'thisMonth')
          usedBandwidth = humanizeBytes.GiB * 20 * 0.81
          usedStorage = humanizeBytes.GiB * 5
          @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)

        afterEach ->
          @usageStub.restore()

        describe 'without a prior email this month', ->
          assertEmailSent 'willUpgradeAccount'
          assertEmailSent.admin 'willUpgradeAccount'

          it 'writes a history record', (done)->
            updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
              expect(err).to.be.null
              AccountEmailHistory.findOne _account: @account._id, (err, aeh)->
                expect(err).to.be.null
                expect(aeh.recordForMonth(new Date, 'willUpgradeAccount')).to.be.ok
                done()

          it 'sends an email to the account', (done)->
            updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
              expect(err).to.be.null
              expect(@mailerSpies[0].calledOnce).to.be.true
              args = @mailerSpies[0].firstCall.args
              expect(args).to.have.length(3)
              expect(args[0]._id.toString()).to.equal(@account._id.toString())
              expect(args[1]).to.equal('basic')
              expect(args[2]).to.be.a('function')
              done()

        describe 'with a prior email this month', ->
          beforeEach (done)->
            @history = new AccountEmailHistory(_account: @account._id)
            @history.history.push
              kind: 'willUpgradeAccount'
              sentAt: new Date
            @history.save done

          it 'does not send an email to the account', (done)->
            updateOrThrottleAccountsWhoCannotPayForOverages done

      describe 'over account limit', ->
        beforeEach ->
          @usageStub = sinon.stub(calculateAccountUsage, 'thisMonth')
          usedBandwidth = humanizeBytes.GiB * 250
          usedStorage = humanizeBytes.GiB * 1000
          @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)

        afterEach ->
          @usageStub.restore()

        it 'does not throttle accounts', (done)->
          updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
            expect(err).to.be.null
            Account.findById @account._id, (err, account)->
              expect(err).to.be.null
              expect(account.throttledAt).to.be.undefined
              done()

        assertEmailSent 'automaticallyUpgradedAccount'
        assertEmailSent.admin 'automaticallyUpgradedAccount'

        it 'updates their plan to the appropriate plan', (done)->
          updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
            expect(err).to.be.null
            Account.findById @account._id, (err, account)->
              expect(err).to.be.null
              expect(account.plans).to.have.length(1)
              expect(account.plans[0]).to.equal('enterprise')
              done()

    describe 'with low bandwidth', ->
      beforeEach ->
        @usageStub = sinon.stub(calculateAccountUsage, 'thisMonth')
        usedBandwidth = humanizeBytes.GiB * 0.9
        usedStorage = humanizeBytes.GiB * 0.9
        @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)

      afterEach ->
        @usageStub.restore()

      it 'does not throttle accounts who have not entered a credit card but are under 1 GiBeezy', (done)->
        updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
          expect(err).to.be.null
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.throttledAt).to.be.undefined
            done()

    describe 'over account limit', ->
      beforeEach ->
        @usageStub = sinon.stub(calculateAccountUsage, 'thisMonth')
        usedBandwidth = humanizeBytes.GiB * 1.1
        usedStorage = humanizeBytes.GiB * 0.9
        @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)

      afterEach ->
        @usageStub.restore()

      assertEmailSent 'throttledAccount'
      assertEmailSent.admin 'throttledAccount'

      it 'throttles accounts which have not entered a credit card if they are over the limit', (done)->
        updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.throttledAt).to.be.instanceOf(Date)
            expect(account.throttledReason).to.equal('overLimit')
            done()

      it 'sends an email to the account', (done)->
        updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
          expect(err).to.be.null
          expect(@mailerSpies[0].calledOnce).to.be.true
          args = @mailerSpies[0].firstCall.args
          expect(args).to.have.length(2)
          expect(args[0]._id.toString()).to.equal(@account._id.toString())
          expect(args[1]).to.be.a('function')
          done()

  describe 'other accounts', ->
    beforeEach (done)->
      @account.billingProvider = 'heroku'
      @account.save done

    describe 'within account limit', ->
      beforeEach ->
        @usageStub = sinon.stub(calculateAccountUsage, 'thisMonth')
        usedBandwidth = humanizeBytes.GiB * 1.1
        usedStorage = humanizeBytes.GiB * 0.9
        @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)

      afterEach ->
        @usageStub.restore()

      it 'does not throttle accounts if they are within their limit', (done)->
        updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
          expect(err).to.be.null
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.throttledAt).to.be.undefined
            done()

    describe 'not in account limit', ->
      beforeEach ->
        @usageStub = sinon.stub(calculateAccountUsage, 'thisMonth')
        usedBandwidth = humanizeBytes.GiB * 110.1
        usedStorage = humanizeBytes.GiB * 0.9
        @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)

      afterEach ->
        @usageStub.restore()

      assertEmailSent 'throttledAccount'
      assertEmailSent.admin 'throttledAccount'

      it 'throttles accounts which are over their limit but cannot pay overages', (done)->
        updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
          expect(err).to.be.null
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.throttledAt).to.be.instanceOf(Date)
            expect(account.throttledReason).to.equal('overLimit')
            done()

      it 'sends an email to the account', (done)->
        updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
          expect(err).to.be.null
          expect(@mailerSpies[0].calledOnce).to.be.true
          args = @mailerSpies[0].firstCall.args
          expect(args).to.have.length(2)
          expect(args[0]._id.toString()).to.equal(@account._id.toString())
          expect(args[1]).to.be.a('function')
          done()

  describe 'special accounts', ->
    beforeEach (done)->
      @account.billingProvider = 'cine.io'
      @account.unthrottleable = true
      @account.save done

    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'thisMonth')
      usedBandwidth = humanizeBytes.GiB * 1.1
      usedStorage = humanizeBytes.GiB * 0.9
      @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)

    afterEach ->
      @usageStub.restore()

    it 'does not throttle accounts which have not entered a credit card if they are over the limit', (done)->
      updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
        Account.findById @account._id, (err, account)->
          expect(err).to.be.null
          expect(account.throttledAt).to.be.undefined
          done()
