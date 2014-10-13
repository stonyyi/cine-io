AccountBillingHistory = Cine.server_model('account_billing_history')
Account = Cine.server_model('account')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'AccountBillingHistory', ->
  modelTimestamps AccountBillingHistory, _account: (new Account)._id

  describe '#billingRecordForMonth and #hasBilledForMonth', ->
    beforeEach (done)->
      @account = new Account(plans: ['basic', 'pro'])
      @account.save done

    beforeEach (done)->
      @thisMonth = new Date
      @lastMonth = new Date
      @lastMonth.setMonth(@lastMonth.getMonth() - 1)
      @twoMonthsAgo = new Date
      @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

      @abh = new AccountBillingHistory(_account: @account._id)
      @abh.history.push
        billingDate: @thisMonth
        stripeChargeId: 'this month charge'
      @abh.history.push
        billingDate: @lastMonth
        stripeChargeId: 'last month charge'
      @abh.save done

    describe '#hasBilledForMonth', ->
      it 'returns true for an abh with a history record for that date', ->
        expect(@abh.hasBilledForMonth(@lastMonth)).to.be.true
        expect(@abh.hasBilledForMonth(@thisMonth)).to.be.true

      it 'returns false for an abh without a history record for that date', ->
        expect(@abh.hasBilledForMonth(@twoMonthsAgo)).to.be.false

    describe '#billingRecordForMonth', ->
      it 'returns a record when there is a record for that date', ->
        expect(@abh.billingRecordForMonth(@thisMonth).stripeChargeId).to.equal("this month charge")
        expect(@abh.billingRecordForMonth(@lastMonth).stripeChargeId).to.equal("last month charge")

      it 'returns null for an abh without a history record for that date', ->
        expect(@abh.billingRecordForMonth(@twoMonthsAgo)).to.be.undefined
