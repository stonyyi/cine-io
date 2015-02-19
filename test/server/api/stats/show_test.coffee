moment = require('moment')
_ = require('underscore')
Show = testApi Cine.api('stats/show')
User = Cine.server_model('user')
Account = Cine.server_model('account')
Project = Cine.server_model('project')
CalculateAccountBandwidth = Cine.server_lib('reporting/broadcast/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/storage/calculate_account_storage')
calculateAndSaveUsageStats = Cine.server_lib("stats/calculate_and_save_usage_stats")
CalcualteAccountPeerMilliseconds = Cine.server_lib('reporting/peer/calculate_account_peer_milliseconds')

describe 'Stats#Show', ->
  testApi.requiresSiteAdmin Show

  beforeEach (done)->
    @siteAdmin = new User(isSiteAdmin: true)
    @siteAdmin.save done

  beforeEach (done)->
    @account1 = new Account billingProvider: 'cine.io', name: "account1 name"
    @account1.save done

  beforeEach (done)->
    @account2 = new Account billingProvider: 'cine.io', name: "account2 name"
    @account2.save done

  beforeEach (done)->
    @account3 = new Account billingProvider: 'cine.io', name: "account3 name"
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
    @month = new Date

  beforeEach ->
    @fakeBandwidth = {}
    @fakeBandwidth[@account1._id.toString()] = 12345
    @fakeBandwidth[@account2._id.toString()] = 54321
    @fakeBandwidth[@account3._id.toString()] = 12121

    @bandwidthStub = sinon.stub CalculateAccountBandwidth, 'byMonth', (account, month, callback)=>
      callback(null, @fakeBandwidth[account._id.toString()])

  afterEach ->
    @bandwidthStub.restore()

  beforeEach ->
    @fakeStorageTotals = {}
    @fakeStorageTotals[@account1._id.toString()] = 111111
    @fakeStorageTotals[@account2._id.toString()] = 666666
    @fakeStorageTotals[@account3._id.toString()] = 333333

    @storageStub = sinon.stub CalculateAccountStorage, 'byMonth', (account, month, callback)=>
      callback(null, @fakeStorageTotals[account._id.toString()])

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
    @keenSuccess = requireFixture('nock/keen/status_check_success')()
    requireFixture('nock/keen/sum_peer_milliseconds_group_by_project') response, @month, (err, @keenNock)=>
      done(err)

  beforeEach (done)->
    calculateAndSaveUsageStats.byMonth @month, done

  assertCorrectResponse = (response)->
    expect(response.id).to.equal('some-stats')
    usageForMonthKey = "usage-#{moment(@month).format("YYYY-MM")}"
    expect(_.keys(response).sort()).to.deep.equal(['id', 'usage'])
    usageForMonth = response.usage[usageForMonthKey]
    expectedResult = {}
    expectedResult[@account1._id.toString()] = {name: 'account1 name', usage: {bandwidth: 12345, storage: 111111, peerMilliseconds: 989898}}
    expectedResult[@account2._id.toString()] = {name: 'account2 name', usage: {bandwidth: 54321, storage: 666666, peerMilliseconds: 787878}}
    expectedResult[@account3._id.toString()] = {name: 'account3 name', usage: {bandwidth: 12121, storage: 333333, peerMilliseconds: 676767}}

    expect(usageForMonth).to.have.length(3)
    _.each usageForMonth, (accountUsageReport)->
      expected = expectedResult[accountUsageReport.id.toString()]
      expect(accountUsageReport.name).to.equal(expected.name)
      expect(accountUsageReport.usage).to.deep.equal(expected.usage)

  it 'returns the usage stats', (done)->
    params = {id: 'some-stats'}
    session = user: @siteAdmin
    callback = (err, response)=>
      expect(err).to.be.null
      assertCorrectResponse.call(this, response)
      done()

    Show params, session, callback

  it 'goes to keen', (done)->
    params = {id: 'some-stats'}
    session = user: @siteAdmin
    callback = (err, response)=>
      expect(err).to.be.null
      expect(@keenSuccess.isDone()).to.be.true
      expect(@keenNock.isDone()).to.be.true
      done()

    Show params, session, callback
