Account = Cine.server_model('account')
ShowUsageReports = testApi Cine.api('usage_reports/show')
CalculateAccountBandwidth = Cine.server_lib('reporting/broadcast/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/storage/calculate_account_storage')

describe 'UsageReports#Show', ->
  testApi.requiresMasterKey ShowUsageReports

  beforeEach (done)->
    @account = new Account billingProvider: 'cine.io', masterKey: 'dat mk', plans: ['free']
    @account.save done

  beforeEach ->
    @thisMonth = new Date
    @lastMonth = new Date
    @lastMonth.setDate(1)
    @lastMonth.setMonth(@lastMonth.getMonth() - 1)
    @twoMonthsAgo = new Date
    @twoMonthsAgo.setDate(1)
    @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

  beforeEach ->
    today = new Date
    today.setDate(1)
    @bandwidthStub = sinon.stub CalculateAccountBandwidth, 'byMonth', (account, date, callback)->
      if date.getMonth() == today.getMonth()
        callback(null, 123)
      else if date.getMonth() == today.getMonth() - 1
        callback(null, 456)
      else if date.getMonth() == today.getMonth() - 2
        callback(null, 789)
      else
        throw new Error("requesting longer date")

  afterEach ->
    @bandwidthStub.restore()

  beforeEach ->
    @storageStub = sinon.stub CalculateAccountStorage, 'total', (account, callback)->
      callback(null, 9937)

  afterEach ->
    @storageStub.restore()

  it 'calculates a usage report', (done)->
    params = {masterKey: 'dat mk'}
    callback = (err, response)=>
      expect(err).to.be.null
      bandwidth = {}
      bandwidth["#{@twoMonthsAgo.getFullYear()}-#{@twoMonthsAgo.getMonth()}"] = 789
      bandwidth["#{@lastMonth.getFullYear()}-#{@lastMonth.getMonth()}"] = 456
      bandwidth["#{@thisMonth.getFullYear()}-#{@thisMonth.getMonth()}"] = 123
      expectedResponse =
        bandwidth: bandwidth
        storage: 9937
        masterKey: 'dat mk'
      expect(response).to.deep.equal(expectedResponse)
      done()

    ShowUsageReports params, callback
