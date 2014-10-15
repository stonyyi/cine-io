chargeAllAccounts = Cine.server_lib('billing/charge_all_accounts')
async = require('async')
Account = Cine.server_model('account')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
billAccountForMonth = Cine.server_lib('billing/bill_account_for_month')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
humanizeBytes = Cine.lib('humanize_bytes')

describe 'chargeAllAccounts', ->

  getDaysInMonth = ->
    now = new Date
    d= new Date(now.getFullYear(), now.getMonth()+1, 0)
    d.getDate()

  it 'requires that it runs on the first of the month', (done)->
    days = (num for num in [2..getDaysInMonth()])
    assertNotCallableOnAnotherDay = (day, callback)->
      thatDay = new Date
      thatDay.setDate(day)
      stub = sinon.stub(Date, 'now').returns(thatDay.getTime())
      chargeAllAccounts (err)->
        expect(err).to.equal("Not running on the first of the month")
        stub.restore()
        callback()
    async.eachSeries days, assertNotCallableOnAnotherDay, done

  describe 'success', ->
    beforeEach (done)->
      @herokuAccount = new Account(billingProvider: 'heroku', plans: ['basic'])
      @herokuAccount.save done
    beforeEach (done)->
      @engineYardAccount = new Account(billingProvider: 'engineyard', plans: ['basic'])
      @engineYardAccount.save done
    beforeEach (done)->
      @appdirectAccount = new Account(billingProvider: 'appdirect', plans: ['basic'])
      @appdirectAccount.save done

    beforeEach (done)->
      @cineioAccount = new Account(billingProvider: 'cine.io', plans: ['basic'])
      @cineioAccount.stripeCustomer.stripeCustomerId = "cus_2ghmxawfvEwXkw"
      @cineioAccount.stripeCustomer.cards.push stripeCardId: "card_102gkI2AL5avr9E4geO0PpkC"
      @cineioAccount.save done

    beforeEach (done)->
      @deletedAccount = new Account(billingProvider: 'cine.io', plans: ['basic'], deletedAt: new Date)
      @deletedAccount.save done

    beforeEach (done)->
      @throttledAccount = new Account(billingProvider: 'cine.io', plans: ['basic'], throttledAt: new Date)
      @throttledAccount.save done

    beforeEach ->
      @billingSpy = sinon.spy billAccountForMonth, '__work'

    afterEach ->
      @billingSpy.restore()

    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'thisMonth')
      usedBandwidth = humanizeBytes.GiB * 155
      usedStorage = humanizeBytes.GiB * 29
      @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)

    afterEach ->
      @usageStub.restore()

    assertEmailSent 'monthlyBill'

    beforeEach ->
      @chargeSuccess = requireFixture('nock/stripe_charge_card_success')(amount: 10000 + (5*80) + (4*80))

    beforeEach ->
      @firstOfMonth = new Date
      @firstOfMonth.setDate(1)
      @dateStub = sinon.stub(Date, 'now').returns(@firstOfMonth.getTime())

    afterEach ->
      @dateStub.restore()

    beforeEach (done)->
      chargeAllAccounts done

    it 'does not try to charge heroku, engineyard, or appdirect accounts', ->
      expect(@billingSpy.callCount).to.equal(1)
      account = @billingSpy.firstCall.args[0]
      expect(account._id.toString()).not.to.equal(@herokuAccount._id.toString())
      expect(account._id.toString()).not.to.equal(@engineYardAccount._id.toString())
      expect(account._id.toString()).not.to.equal(@appdirectAccount._id.toString())

    it 'does not try to charge deleted accounts', ->
      expect(@billingSpy.callCount).to.equal(1)
      account = @billingSpy.firstCall.args[0]
      expect(account._id.toString()).not.to.equal(@deletedAccount._id.toString())

    it 'does not try to charge throttled accounts', ->
      expect(@billingSpy.callCount).to.equal(1)
      account = @billingSpy.firstCall.args[0]
      expect(account._id.toString()).not.to.equal(@throttledAccount._id.toString())

    it 'charges cine.io accounts for the previous month', ->
      expect(@billingSpy.callCount).to.equal(1)
      account = @billingSpy.firstCall.args[0]
      expect(account._id.toString()).to.equal(@cineioAccount._id.toString())

      month = @billingSpy.firstCall.args[1]
      lastOfMonth = new Date(@firstOfMonth.toString())
      lastOfMonth.setDate(lastOfMonth.getDate() - 1)
      expect(month.toString()).to.equal(lastOfMonth.toString())
