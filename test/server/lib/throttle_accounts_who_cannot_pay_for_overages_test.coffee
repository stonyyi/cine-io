throttleAccountsWhoCannotPayForOverages = Cine.server_lib('throttle_accounts_who_cannot_pay_for_overages')
Account = Cine.server_model("account")
humanizeBytes = Cine.lib('humanize_bytes')
mailer = Cine.server_lib("mailer")
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')

describe 'throttleAccountsWhoCannotPayForOverages', ->
  beforeEach (done)->
    @account = new Account(plans: ['solo'])
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

      beforeEach ->
        @usageStub = sinon.stub(calculateAccountUsage, 'thisMonth')
        usedBandwidth = humanizeBytes.GiB * 250
        usedStorage = humanizeBytes.GiB * 1000
        @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)

      afterEach ->
        @usageStub.restore()

      it 'does not throttle accounts who have a credit card, regardless of usage', (done)->
        throttleAccountsWhoCannotPayForOverages (err)=>
          expect(err).to.be.null
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.throttledAt).to.be.undefined
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
        throttleAccountsWhoCannotPayForOverages (err)=>
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
        throttleAccountsWhoCannotPayForOverages (err)=>
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.throttledAt).to.be.instanceOf(Date)
            done()

      it 'sends an email to the account', (done)->
        throttleAccountsWhoCannotPayForOverages (err)=>
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
        throttleAccountsWhoCannotPayForOverages (err)=>
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
        throttleAccountsWhoCannotPayForOverages (err)=>
          expect(err).to.be.null
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.throttledAt).to.be.instanceOf(Date)
            done()

      it 'sends an email to the account', (done)->
        throttleAccountsWhoCannotPayForOverages (err)=>
          expect(err).to.be.null
          expect(@mailerSpies[0].calledOnce).to.be.true
          args = @mailerSpies[0].firstCall.args
          expect(args).to.have.length(2)
          expect(args[0]._id.toString()).to.equal(@account._id.toString())
          expect(args[1]).to.be.a('function')
          done()
