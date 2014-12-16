AccountBillingHistory = Cine.server_model('account_billing_history')
Account = Cine.server_model('account')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'AccountBillingHistory', ->
  modelTimestamps AccountBillingHistory, _account: (new Account)._id

  describe '#billingRecordForMonth and #hasBilledForMonth', ->
    beforeEach (done)->
      @account = new Account(billingProvider: 'cine.io', productPlans: {broadcast: ['basic', 'pro']})
      @account.save done

    beforeEach (done)->
      @thisMonth = new Date
      @lastMonth = new Date
      @lastMonth.setDate(1)
      @lastMonth.setMonth(@lastMonth.getMonth() - 1)
      @twoMonthsAgo = new Date
      @twoMonthsAgo.setDate(1)
      @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

      @threeMonthsAgo = new Date
      @threeMonthsAgo.setDate(1)
      @threeMonthsAgo.setMonth(@threeMonthsAgo.getMonth() - 3)

      @fourMonthsAgo = new Date
      @fourMonthsAgo.setDate(1)
      @fourMonthsAgo.setMonth(@fourMonthsAgo.getMonth() - 4)

      @abh = new AccountBillingHistory(_account: @account._id)
      @abh.history.push
        billingDate: @thisMonth
        paid: true
        stripeChargeId: 'this month charge'
      @abh.history.push
        billingDate: @lastMonth
        paid: true
        stripeChargeId: 'last month charge'
      @abh.history.push
        billingDate: @threeMonthsAgo
        paid: false
        stripeChargeId: 'three months ago month charge'
      @abh.history.push
        billingDate: @fourMonthsAgo
        paid: false
        notCharged: true
      @abh.save done

    describe '#hasBilledForMonth', ->
      it 'returns true for an abh with a history record for that date', ->
        expect(@abh.hasBilledForMonth(@lastMonth)).to.be.true
        expect(@abh.hasBilledForMonth(@thisMonth)).to.be.true

      it 'returns false for an abh without a history record for that date', ->
        expect(@abh.hasBilledForMonth(@twoMonthsAgo)).to.be.false

      it 'returns false for an abh with a history record for that date but was not paid', ->
        expect(@abh.hasBilledForMonth(@threeMonthsAgo)).to.be.false

      it 'returns true for an abh with a history record for that date but was not paid but was not charged', ->
        expect(@abh.hasBilledForMonth(@fourMonthsAgo)).to.be.true

    describe '#billingRecordForMonth', ->
      it 'returns a record when there is a record for that date', ->
        expect(@abh.billingRecordForMonth(@thisMonth).stripeChargeId).to.equal("this month charge")
        expect(@abh.billingRecordForMonth(@lastMonth).stripeChargeId).to.equal("last month charge")

      it 'returns null for an abh without a history record for that date', ->
        expect(@abh.billingRecordForMonth(@twoMonthsAgo)).to.be.undefined
