chargeAllAccounts = Cine.server_lib('billing/charge_all_accounts')
async = require('async')
Account = Cine.server_model('account')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
chargeAccountForMonth = Cine.server_lib('billing/charge_account_for_month')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
humanizeBytes = Cine.lib('humanize_bytes')
getDaysInMonth = Cine.server_lib('get_days_in_month')

describe 'chargeAllAccounts', ->

  it 'requires that it runs on the first of the month', (done)->
    days = (num for num in [2..getDaysInMonth(new Date)])
    assertNotCallableOnAnotherDay = (day, callback)->
      thatDay = new Date
      thatDay.setDate(day)
      dateStub = sinon.stub Date, 'now', ->
        dateStub.restore()
        thatDay.getTime()
      chargeAllAccounts (err)->
        expect(err).to.equal("Not running on the first of the month")
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
      dateStub = sinon.stub Date, 'now', =>
        dateStub.restore()
        @firstOfMonth.getTime()
    describe 'success', ->

      beforeEach ->
        @chargeSuccess = requireFixture('nock/stripe_charge_card_success')(amount: 10000)

      assertEmailSent 'monthlyBill'

      it 'does not try to charge heroku, engineyard, or appdirect accounts', (done)->
        stubDate()
        chargeAllAccounts (err)=>
          expect(err).to.be.undefined
          expect(@billingSpy.callCount).to.equal(1)
          account = @billingSpy.firstCall.args[0]
          expect(account._id.toString()).not.to.equal(@herokuAccount._id.toString())
          expect(account._id.toString()).not.to.equal(@engineYardAccount._id.toString())
          expect(account._id.toString()).not.to.equal(@appdirectAccount._id.toString())
          done()

      it 'does not try to charge deleted accounts', (done)->
        stubDate.call(this)
        chargeAllAccounts (err)=>
          expect(err).to.be.undefined
          expect(@billingSpy.callCount).to.equal(1)
          account = @billingSpy.firstCall.args[0]
          expect(account._id.toString()).not.to.equal(@deletedAccount._id.toString())
          done()

      it 'does not try to charge throttled accounts', (done)->
        stubDate.call(this)
        chargeAllAccounts (err)=>
          expect(err).to.be.undefined
          expect(@billingSpy.callCount).to.equal(1)
          account = @billingSpy.firstCall.args[0]
          expect(account._id.toString()).not.to.equal(@throttledAccount._id.toString())
          done()

      it 'charges cine.io accounts for the previous month', (done)->
        stubDate.call(this)
        chargeAllAccounts (err)=>
          expect(err).to.be.undefined
          expect(@billingSpy.callCount).to.equal(1)
          account = @billingSpy.firstCall.args[0]
          expect(account._id.toString()).to.equal(@cineioAccount._id.toString())

          month = @billingSpy.firstCall.args[1]
          lastOfMonth = new Date(@firstOfMonth.toString())
          lastOfMonth.setDate(lastOfMonth.getDate() - 1)
          expect(month.toString()).to.equal(lastOfMonth.toString())
          done()


    describe 'failure', ->
      beforeEach (done)->
        @cineioAccount.stripeCustomer.stripeCustomerId = undefined
        @cineioAccount.save done

      it 'aggregates the errors', (done)->
        stubDate.call(this)
        chargeAllAccounts (err)=>
          expect(err).to.have.length(1)
          expect(err[0]).to.equal('account not stripe customer')
          expect(@billingSpy.callCount).to.equal(1)
          account = @billingSpy.firstCall.args[0]
          expect(account._id.toString()).to.equal(@cineioAccount._id.toString())

          month = @billingSpy.firstCall.args[1]
          lastOfMonth = new Date(@firstOfMonth.toString())
          lastOfMonth.setDate(lastOfMonth.getDate() - 1)
          expect(month.toString()).to.equal(lastOfMonth.toString())
          done()
