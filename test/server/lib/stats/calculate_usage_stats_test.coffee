calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Account = Cine.server_model('account')
CalculateAccountBandwidth = Cine.server_lib('reporting/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/calculate_account_storage')

describe 'calculateUsageStats', ->
  beforeEach (done)->
    @account1 = new Account billingProvider: 'cine.io'
    @account1.save done

  beforeEach (done)->
    @account2 = new Account billingProvider: 'cine.io'
    @account2.save done

  beforeEach (done)->
    @account3 = new Account billingProvider: 'cine.io'
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

    @bandwidthStub = sinon.stub CalculateAccountBandwidth, 'byMonth', (account, month, callback)=>
      resource = if month.getYear() == (new Date).getYear() then @fakeBandwidthThisMonth else @fakeBandwidthByMonth
      callback(null, resource[account._id.toString()])

  afterEach ->
    @bandwidthStub.restore()

  beforeEach ->
    @fakeStorageThisMonth = {}
    @fakeStorageThisMonth[@account1._id.toString()] = 111111
    @fakeStorageThisMonth[@account2._id.toString()] = 666666
    @fakeStorageThisMonth[@account3._id.toString()] = 333333

    @fakeStorageByMonth = {}
    @fakeStorageByMonth[@account1._id.toString()] = 222222
    @fakeStorageByMonth[@account2._id.toString()] = 444444
    @fakeStorageByMonth[@account3._id.toString()] = 555555

    @storageStub = sinon.stub CalculateAccountStorage, 'byMonth', (account, month, callback)=>
      resource = if month.getYear() == (new Date).getYear() then @fakeStorageThisMonth else @fakeStorageByMonth
      callback(null, resource[account._id.toString()])

  afterEach ->
    @storageStub.restore()

  describe 'thisMonth', ->
    it 'calculates the stats for each account', (done)->
      expected = {}
      expected[@account1._id.toString()] =
        bandwidth: 12345
        storage: 111111
      expected[@account2._id.toString()] =
        bandwidth: 54321
        storage: 666666
      expected[@account3._id.toString()] =
        bandwidth: 12121
        storage: 333333
      calculateUsageStats.thisMonth (err, results)->
        expect(err).to.be.null
        expect(results).to.deep.equal(expected)
        done()

  describe 'byMonth', ->
    it 'calculates the stats for each account', (done)->
      d = new Date
      d.setYear(d.getYear() - 1)
      expected = {}
      expected[@account1._id.toString()] =
        bandwidth: 99999
        storage: 222222
      expected[@account2._id.toString()] =
        bandwidth: 88888
        storage: 444444
      expected[@account3._id.toString()] =
        bandwidth: 77777
        storage: 555555

      calculateUsageStats.byMonth d, (err, results)->
        expect(err).to.be.null
        expect(results).to.deep.equal(expected)
        done()
