calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Account = Cine.server_model('account')
Project = Cine.server_model('project')
CalculateAccountBandwidth = Cine.server_lib('reporting/broadcast/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/storage/calculate_account_storage')
CalcualteAccountPeerMilliseconds = Cine.server_lib('reporting/peer/calculate_account_peer_milliseconds')

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

  beforeEach (done)->
    @project1 = new Project _account: @account1._id
    @project1.save(done)

  beforeEach (done)->
    @project2 = new Project _account: @account2._id
    @project2.save(done)

  beforeEach (done)->
    @project3 = new Project _account: @account3._id
    @project3.save(done)

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

  beforeEach (done)->
    result1 =
      projectId: @project1._id.toString()
      result: 989898
    result2 =
      projectId: @project2._id.toString()
      result: 787878
    result3 =
      projectId: @project3._id.toString()
      result: 676767
    response =
      [result1, result2, result3]
    requireFixture('nock/keen/sum_peer_milliseconds_group_by_project') response, new Date, (err, @keenNock)=>
      done(err)

  beforeEach (done)->
    result1 =
      projectId: @project1._id.toString()
      result: 565656
    result2 =
      projectId: @project2._id.toString()
      result: 454545
    result3 =
      projectId: @project3._id.toString()
      result: 343434
    response =
      [result1, result2, result3]
    d = new Date
    d.setYear(d.getYear() - 1)
    requireFixture('nock/keen/sum_peer_milliseconds_group_by_project') response, d, (err, @keenNock2)=>
      done(err)

  describe 'thisMonth', ->
    it 'calculates the stats for each account', (done)->
      expected = {}
      expected[@account1._id.toString()] =
        bandwidth: 12345
        storage: 111111
        peerMilliseconds: 989898
      expected[@account2._id.toString()] =
        bandwidth: 54321
        storage: 666666
        peerMilliseconds: 787878
      expected[@account3._id.toString()] =
        bandwidth: 12121
        storage: 333333
        peerMilliseconds: 676767
      calculateUsageStats.thisMonth (err, results)->
        expect(err).to.be.null
        expect(results).to.deep.equal(expected)
        done()

    it 'calls out to keen', (done)->
      calculateUsageStats.thisMonth (err, results)=>
        expect(err).to.be.null
        expect(@keenNock.isDone()).to.be.true
        done()

  describe 'byMonth', ->
    it 'calculates the stats for each account', (done)->
      d = new Date
      d.setYear(d.getYear() - 1)
      expected = {}
      expected[@account1._id.toString()] =
        bandwidth: 99999
        storage: 222222
        peerMilliseconds: 565656
      expected[@account2._id.toString()] =
        bandwidth: 88888
        storage: 444444
        peerMilliseconds: 454545
      expected[@account3._id.toString()] =
        bandwidth: 77777
        storage: 555555
        peerMilliseconds: 343434

      calculateUsageStats.byMonth d, (err, results)->
        expect(err).to.be.null
        expect(results).to.deep.equal(expected)
        done()

    it 'calls out to keen', (done)->
      d = new Date
      d.setYear(d.getYear() - 1)

      calculateUsageStats.byMonth d, (err, results)=>
        expect(err).to.be.null
        expect(@keenNock2.isDone()).to.be.true
        done()
