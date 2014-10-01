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
    @fakeBandwidth = {}
    @fakeBandwidth[@account1._id.toString()] = 12345
    @fakeBandwidth[@account2._id.toString()] = 54321
    @fakeBandwidth[@account3._id.toString()] = 12121

    @bandwidthStub = sinon.stub CalculateAccountUsage, 'byMonth', (account, month, callback)=>
      callback(null, @fakeBandwidth[account._id.toString()])

  afterEach ->
    @bandwidthStub.restore()

  describe 'thisMonth', ->
    it 'calculates the stats for each account', (done)->
      calculateUsageStats.thisMonth (err, results)=>
        expect(err).to.be.null
        expect(results).to.deep.equal(@fakeBandwidth)
        done()
