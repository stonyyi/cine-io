calculateAccountUsage = Cine.server_lib("reporting/calculate_account_usage")
Account = Cine.server_model('account')
Project = Cine.server_model('project')
CalculateAccountBandwidth = Cine.server_lib('reporting/broadcast/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/storage/calculate_account_storage')
CalcualteAccountPeerMilliseconds = Cine.server_lib('reporting/peer/calculate_account_peer_milliseconds')

describe 'calculateAccountUsage', ->
  beforeEach (done)->
    @account = new Account billingProvider: 'cine.io'
    @account.save done

  beforeEach (done)->
    @project1 = new Project _account: @account._id
    @project1.save done

  beforeEach ->
    @fakeBandwidthThisMonth = {}
    @fakeBandwidthThisMonth[@account._id.toString()] = 12345

    @fakeBandwidthByMonth = {}
    @fakeBandwidthByMonth[@account._id.toString()] = 99999

    @bandwidthStub = sinon.stub CalculateAccountBandwidth, 'byMonth', (account, month, callback)=>
      resource = if month.getYear() == (new Date).getYear() then @fakeBandwidthThisMonth else @fakeBandwidthByMonth
      callback(null, resource[account._id.toString()])

  afterEach ->
    @bandwidthStub.restore()

  beforeEach ->
    @fakeStorageThisMonth = {}
    @fakeStorageThisMonth[@account._id.toString()] = 111111

    @fakeStorageByMonth = {}
    @fakeStorageByMonth[@account._id.toString()] = 2222222

    @storageStub = sinon.stub CalculateAccountStorage, 'byMonth', (account, month, callback)=>
      resource = if month.getYear() == (new Date).getYear() then @fakeStorageThisMonth else @fakeStorageByMonth
      callback(null, resource[account._id.toString()])

  afterEach ->
    @storageStub.restore()

  beforeEach ->
    @fakePeerMillisecondsThisMonth = {}
    @fakePeerMillisecondsThisMonth[@account._id.toString()] = 333333

    @fakePeerMillisecondsByMonth = {}
    @fakePeerMillisecondsByMonth[@account._id.toString()] = 444444

    @peerStub = sinon.stub CalcualteAccountPeerMilliseconds, 'byMonth', (account, month, callback)=>
      resource = if month.getYear() == (new Date).getYear() then @fakePeerMillisecondsThisMonth else @fakePeerMillisecondsByMonth
      callback(null, resource[account._id.toString()])

  afterEach ->
    @peerStub.restore()

  describe 'thisMonth', ->
    it 'calculates the stats for each account', (done)->
      expected =
        bandwidth: 12345
        storage: 111111
        peerMilliseconds: 333333

      calculateAccountUsage.thisMonth @account, (err, results)->
        expect(err).to.be.undefined
        expect(results).to.deep.equal(expected)
        done()

  describe 'byMonth', ->
    it 'calculates the stats for each account', (done)->
      d = new Date
      d.setYear(d.getYear() - 1)
      expected =
        bandwidth: 99999
        storage: 2222222
        peerMilliseconds: 444444

      calculateAccountUsage.byMonth @account, d, (err, results)->
        expect(err).to.be.undefined
        expect(results).to.deep.equal(expected)
        done()

  describe 'byMonthWithKeenMilliseconds', (done)->
    it 'calculates the stats for each account', (done)->
      d = new Date
      d.setYear(d.getYear() - 1)
      keenResults = {}
      keenResults[@project1._id.toString()] = 1234
      expected =
        bandwidth: 99999
        storage: 2222222
        peerMilliseconds: 1234

      calculateAccountUsage.byMonthWithKeenMilliseconds @account, d, keenResults, (err, results)->
        expect(err).to.be.undefined
        expect(results).to.deep.equal(expected)
        done()
