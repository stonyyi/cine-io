updateOrThrottleAccountsWhoCannotPayForOverages = Cine.server_lib('billing/update_or_throttle_accounts_who_cannot_pay_for_overages')
Account = Cine.server_model("account")
Project = Cine.server_model("project")
AccountEmailHistory = Cine.server_model("account_email_history")
humanizeBytes = Cine.lib('humanize_bytes')
mailer = Cine.server_lib("mailer")
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
calculateAndSaveUsageStats = Cine.server_lib("stats/calculate_and_save_usage_stats")

THOUSAND = 1000
MINUTES = 60 * THOUSAND # in milliseconds

describe 'updateOrThrottleAccountsWhoCannotPayForOverages', ->
  beforeEach ->
    @month = new Date

  beforeEach (done)->
    @account = new Account(billingProvider: 'cine.io', productPlans: {broadcast: ['solo'], peer: ['basic']})
    @account.save done

  beforeEach (done)->
    @project = new Project(_account: @account._id)
    @project.save done

  stubUsage = (options)->
    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'byMonthWithKeenMilliseconds')
      @usageStub.callsArgWith(3, null, bandwidth: options.bandwidth, storage: options.storage, peerMilliseconds: options.peerMilliseconds)

    afterEach ->
      @usageStub.restore()

    beforeEach ->
      @keenSuccess = requireFixture('nock/keen/status_check_success')()

    beforeEach (done)->
      result1 =
        projectId: @project._id.toString()
        result: options.peerMilliseconds
      response =
        [result1]

      firstSecondInMonth = new Date(@month.getFullYear(), @month.getMonth(), 1)
      lastSecondInMonth = new Date(@month.getFullYear(), @month.getMonth() + 1)
      lastSecondInMonth.setSeconds(-1)

      requireFixture('nock/keen/sum_peer_milliseconds_group_by_project') response, firstSecondInMonth, lastSecondInMonth, (err, @keenNock)=>
        done(err)

    beforeEach (done)->
      calculateAndSaveUsageStats.byMonth @month, done

  describe 'cine.io accounts', ->
    beforeEach (done)->
      @account.billingProvider = 'cine.io'
      @account.save done

    describe 'with a credit card', ->

      beforeEach (done)->
        @account.stripeCustomer.stripeCustomerId = "cus_2ghmxawfvEwXkw"
        @account.stripeCustomer.cards.push stripeCardId: "card_102gkI2AL5avr9E4geO0PpkC"
        @account.save done

      describe '80% of account limit for broadcast', ->
        stubUsage
          bandwidth: humanizeBytes.GiB * 20 * 0.81
          storage: humanizeBytes.GiB * 5

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

      describe '80% of account limit for peer', ->

        stubUsage
          bandwidth: humanizeBytes.GiB
          storage: humanizeBytes.GiB
          peerMilliseconds: 11.3 * THOUSAND * MINUTES

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
        stubUsage
          bandwidth: humanizeBytes.GiB * 250
          storage: humanizeBytes.GiB * 1000
          peerMilliseconds: 13 * THOUSAND * MINUTES

        assertEmailSent 'automaticallyUpgradedAccount'
        assertEmailSent.admin 'automaticallyUpgradedAccount'

        it 'does not throttle accounts', (done)->
          updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
            expect(err).to.be.null
            Account.findById @account._id, (err, account)->
              expect(err).to.be.null
              expect(account.throttledAt).to.be.undefined
              done()

        it 'updates their plan to the appropriate plan', (done)->
          updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
            expect(err).to.be.null
            Account.findById @account._id, (err, account)->
              expect(err).to.be.null
              expect(account.productPlans.peer).to.have.length(1)
              expect(account.productPlans.broadcast).to.have.length(1)
              expect(account.productPlans.broadcast[0]).to.equal('enterprise')
              expect(account.productPlans.peer[0]).to.equal('premium')
              done()

    describe 'with low bandwidth', ->
      stubUsage
        bandwidth: humanizeBytes.GiB * 0.9
        storage: humanizeBytes.GiB * 0.9

      it 'does not throttle accounts who have not entered a credit card but are under 1 GiBeezy', (done)->
        updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
          expect(err).to.be.null
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.throttledAt).to.be.undefined
            done()

    describe 'over account limit for broadcast', ->
      stubUsage
        bandwidth: humanizeBytes.GiB * 1.1
        storage: humanizeBytes.GiB * 0.9
        peerMilliseconds: 1 * MINUTES

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

    describe 'over account limit for peer', ->
      stubUsage
        bandwidth: humanizeBytes.GiB
        storage: humanizeBytes.GiB
        peerMilliseconds: 13 * THOUSAND * MINUTES

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
      @account.productPlans = {broadcast: ['solo']}
      @account.save done

    describe 'within account limit', ->
      stubUsage
        bandwidth: humanizeBytes.GiB * 1.1
        storage: humanizeBytes.GiB * 0.9

      it 'does not throttle accounts if they are within their limit', (done)->
        updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
          expect(err).to.be.null
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.throttledAt).to.be.undefined
            done()

    describe 'not in account limit', ->
      stubUsage
        bandwidth: humanizeBytes.GiB * 110.1
        storage: humanizeBytes.GiB * 0.9

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

    stubUsage
      bandwidth: humanizeBytes.GiB * 1.1
      storage: humanizeBytes.GiB * 0.9

    it 'does not throttle accounts which have not entered a credit card if they are over the limit', (done)->
      updateOrThrottleAccountsWhoCannotPayForOverages (err)=>
        Account.findById @account._id, (err, account)->
          expect(err).to.be.null
          expect(account.throttledAt).to.be.undefined
          done()
