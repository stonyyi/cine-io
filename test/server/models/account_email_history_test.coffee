AccountEmailHistory = Cine.server_model('account_email_history')
Account = Cine.server_model('account')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'AccountEmailHistory', ->
  modelTimestamps AccountEmailHistory, _account: (new Account)._id

  describe '#recordForMonth', ->
    beforeEach (done)->
      @account = new Account(billingProvider: 'cine.io', plans: ['basic', 'pro'])
      @account.save done

    beforeEach (done)->
      @thisMonth = new Date
      @lastMonth = new Date
      @lastMonth.setDate(1)
      @lastMonth.setMonth(@lastMonth.getMonth() - 1)
      @twoMonthsAgo = new Date
      @twoMonthsAgo.setDate(1)
      @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

      @aeh = new AccountEmailHistory(_account: @account._id)
      @aeh.history.push
        sentAt: @thisMonth
        kind: 'some-kind'
      @aeh.history.push
        sentAt: @lastMonth
        kind: 'some-other-kind'
      @aeh.save done

    it 'returns a record when there is a record for that date', ->
      expect(@aeh.recordForMonth(@thisMonth, 'some-kind').sentAt).to.equal(@thisMonth)
      expect(@aeh.recordForMonth(@lastMonth, 'some-other-kind').sentAt).to.equal(@lastMonth)

    it 'returns null for an aeh without a history record for that date with that kind', ->
      expect(@aeh.recordForMonth(@lastMonth, 'some-kind')).to.be.undefined

    it 'returns null for an aeh without a history record for that date', ->
      expect(@aeh.recordForMonth(@twoMonthsAgo, 'some-kind')).to.be.undefined
