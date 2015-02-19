Account = Cine.server_model('account')
ShowUsageReportsAccount = testApi Cine.api('usage/accounts/show')
CalculateAccountBandwidth = Cine.server_lib('reporting/broadcast/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/storage/calculate_account_storage')
CalcualteAccountPeerMilliseconds = Cine.server_lib('reporting/peer/calculate_account_peer_milliseconds')

describe 'UsageReports/Accounts#Show', ->
  testApi.requiresMasterKey ShowUsageReportsAccount

  beforeEach (done)->
    @account = new Account billingProvider: 'cine.io', masterKey: 'dat mk', productPlans: {broadcast: ['free'], peer: ['free']}
    @account.save done

  beforeEach ->
    @thisMonth = new Date
    @lastMonth = new Date
    @lastMonth.setDate(1)
    @lastMonth.setMonth(@lastMonth.getMonth() - 1)
    @twoMonthsAgo = new Date
    @twoMonthsAgo.setDate(1)
    @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

  monthIsLastMonth = (monthNumber, nowMonthNumber)->
    (monthNumber == nowMonthNumber - 1) || checkLastMonthYearRollover(monthNumber, nowMonthNumber)

  monthIsTwoMonthsAgo = (monthNumber, nowMonthNumber)->
    (monthNumber == nowMonthNumber - 2) || checkForYearRollover(monthNumber, nowMonthNumber)

  checkLastMonthYearRollover = (monthNumber, nowMonthNumber)->
    monthNumber == 11 && nowMonthNumber == 0

  checkForYearRollover = (monthNumber, nowMonthNumber)->
    (monthNumber == 10 && nowMonthNumber == 0) ||
    (monthNumber == 11 && nowMonthNumber == 1)

  beforeEach ->
    today = new Date
    today.setDate(1)
    @bandwidthStub = sinon.stub CalculateAccountBandwidth, 'byMonth', (account, date, callback)->
      if date.getMonth() == today.getMonth()
        callback(null, 123)
      else if monthIsLastMonth(date.getMonth(), today.getMonth())
        callback(null, 456)
      else if monthIsTwoMonthsAgo(date.getMonth(), today.getMonth())
        callback(null, 789)
      else
        throw new Error("requesting longer date")

  afterEach ->
    @bandwidthStub.restore()

  beforeEach ->
    today = new Date
    today.setDate(1)
    @peerStub = sinon.stub CalcualteAccountPeerMilliseconds, 'byMonth', (account, date, callback)->
      if date.getMonth() == today.getMonth()
        callback(null, 111)
      else if monthIsLastMonth(date.getMonth(), today.getMonth())
        callback(null, 222)
      else if monthIsTwoMonthsAgo(date.getMonth(), today.getMonth())
        callback(null, 333)
      else
        throw new Error("requesting longer date")

  afterEach ->
    @peerStub.restore()

  beforeEach ->
    @storageStub = sinon.stub CalculateAccountStorage, 'total', (account, callback)->
      callback(null, 9937)

  afterEach ->
    @storageStub.restore()

  it 'returns empty when not asked for any report', (done)->
    params = {masterKey: 'dat mk', report: []}
    callback = (err, response)->
      expect(err).to.be.null
      expectedResponse =
        masterKey: 'dat mk'
      expect(response).to.deep.equal(expectedResponse)
      done()

    ShowUsageReportsAccount params, callback

  it 'calculates a usage report', (done)->
    params = {masterKey: 'dat mk', report: ['bandwidth', 'storage', 'peerMilliseconds']}
    callback = (err, response)=>
      expect(err).to.be.null
      bandwidth = {}
      peerMilliseconds = {}
      bandwidth["#{@twoMonthsAgo.getFullYear()}-#{@twoMonthsAgo.getMonth()}"] = 789
      bandwidth["#{@lastMonth.getFullYear()}-#{@lastMonth.getMonth()}"] = 456
      bandwidth["#{@thisMonth.getFullYear()}-#{@thisMonth.getMonth()}"] = 123
      peerMilliseconds["#{@twoMonthsAgo.getFullYear()}-#{@twoMonthsAgo.getMonth()}"] = 333
      peerMilliseconds["#{@lastMonth.getFullYear()}-#{@lastMonth.getMonth()}"] = 222
      peerMilliseconds["#{@thisMonth.getFullYear()}-#{@thisMonth.getMonth()}"] = 111
      expectedResponse =
        bandwidth: bandwidth
        peerMilliseconds: peerMilliseconds
        storage: 9937
        masterKey: 'dat mk'
      expect(response).to.deep.equal(expectedResponse)
      done()

    ShowUsageReportsAccount params, callback
