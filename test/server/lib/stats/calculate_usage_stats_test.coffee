calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Account = Cine.server_model('account')
CalculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')

describe 'calculateUsageStats', ->
  beforeEach (done)->
    @account1 = new Account
    @account1.save done

  beforeEach (done)->
    @account2 = new Account
    @account2.save done

  beforeEach (done)->
    @account3 = new Account
    @account3.save done

  beforeEach ->
    @fakeBandwidthThisMonth = {}
    @fakeBandwidthThisMonth[@account1._id.toString()] = 12345
    @fakeBandwidthThisMonth[@account2._id.toString()] = 54321
    @fakeBandwidthThisMonth[@account3._id.toString()] = 12121

    @fakeBandwidthByMonth = {}
    @fakeBandwidthByMonth[@account1._id.toString()] = 99999
    @fakeBandwidthByMonth[@account2._id.toString()] = 88888
    @fakeBandwidthByMonth[@account3._id.toString()] = 77777

    @bandwidthStub = sinon.stub CalculateAccountUsage, 'byMonth', (account, month, callback)=>
      resource = if month.getYear() == (new Date).getYear() then @fakeBandwidthThisMonth else @fakeBandwidthByMonth
      callback(null, resource[account._id.toString()])

  afterEach ->
    @bandwidthStub.restore()

  describe 'thisMonth', ->
    it 'calculates the stats for each account', (done)->
      calculateUsageStats.thisMonth (err, results)=>
        expect(err).to.be.null
        expect(results).to.deep.equal(@fakeBandwidthThisMonth)
        done()

  describe 'byMonth', ->
    it 'calculates the stats for each account', (done)->
      d = new Date
      d.setYear(d.getYear() - 1)
      calculateUsageStats.byMonth d, (err, results)=>
        expect(err).to.be.null
        expect(results).to.deep.equal(@fakeBandwidthByMonth)
        done()
