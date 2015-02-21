chargeAllAccountsIfOnTheFirstOfTheMonth = Cine.server_lib('billing/charge_all_accounts_if_on_the_first_of_the_month')
async = require('async')
Account = Cine.server_model('account')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
chargeAccountForMonth = Cine.server_lib('billing/charge_account_for_month')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
humanizeBytes = Cine.lib('humanize_bytes')
getDaysInMonth = Cine.server_lib('get_days_in_month')

describe 'chargeAllAccountsIfOnTheFirstOfTheMonth', ->

  it 'requires that it runs on the first of the month', (done)->
    days = (num for num in [2..getDaysInMonth(new Date)])
    assertNotCallableOnAnotherDay = (day, callback)->
      thatDay = new Date
      thatDay.setDate(day)
      dateStub = sinon.stub Date, 'now', ->
        dateStub.restore()
        thatDay.getTime()
      chargeAllAccountsIfOnTheFirstOfTheMonth (err)->
        expect(err).to.be.undefined
        callback()
    async.eachSeries days, assertNotCallableOnAnotherDay, done

  describe 'success', ->

    beforeEach (done)->
      @cineioAccount = new Account(billingProvider: 'cine.io', productPlans: {broadcast: ['basic']})
      @cineioAccount.stripeCustomer.stripeCustomerId = "cus_2ghmxawfvEwXkw"
      @cineioAccount.stripeCustomer.cards.push stripeCardId: "card_102gkI2AL5avr9E4geO0PpkC"
      @cineioAccount.save done

    beforeEach ->
      @billingSpy = sinon.spy chargeAccountForMonth, '__work'

    afterEach ->
      @billingSpy.restore()

    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'byMonth')
      usedBandwidth = humanizeBytes.GiB * 155
      usedStorage = humanizeBytes.GiB * 29
      @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)

    afterEach ->
      @usageStub.restore()

    stubDate = ->
      @firstOfMonth = new Date
      @firstOfMonth.setDate(1)
      callCount = 0
      dateStub = sinon.stub Date, 'now', =>
        callCount++
        dateStub.restore() if callCount == 2 #one for this lib, one for the double check on chargeAllAccounts
        @firstOfMonth.getTime()

    describe 'success', ->

      beforeEach ->
        @chargeSuccess = requireFixture('nock/stripe_charge_card_success')(amount: 10000)

      assertEmailSent 'monthlyBill'
      assertEmailSent.admin 'chargedAllAccounts'

      it 'charges cine.io accounts for the previous month', (done)->
        stubDate.call(this)
        chargeAllAccountsIfOnTheFirstOfTheMonth (err)=>
          expect(err).to.be.undefined
          expect(@billingSpy.callCount).to.equal(1)
          account = @billingSpy.firstCall.args[0]
          expect(account._id.toString()).to.equal(@cineioAccount._id.toString())

          month = @billingSpy.firstCall.args[1]
          lastOfMonth = new Date(@firstOfMonth.toString())
          lastOfMonth.setDate(lastOfMonth.getDate() - 1)
          expect(month.toString()).to.equal(lastOfMonth.toString())
          done()
