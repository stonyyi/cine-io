calculateAccountUsage = Cine.server_lib("reporting/calculate_account_usage")
Account = Cine.server_model('account')
CalculateAccountBandwidth = Cine.server_lib('reporting/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/calculate_account_storage')

describe 'calculateAccountUsage', ->
  beforeEach (done)->
    @account = new Account
    @account.save done

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
    @fakeStorageTotals = {}
    @fakeStorageTotals[@account._id.toString()] = 111111

    @storageStub = sinon.stub CalculateAccountStorage, 'total', (account, callback)=>
      callback(null, @fakeStorageTotals[account._id.toString()])

  afterEach ->
    @storageStub.restore()

  describe 'thisMonth', ->
    it 'calculates the stats for each account', (done)->
      expected =
        bandwidth: 12345
        storage: 111111

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
        storage: 111111

      calculateAccountUsage.byMonth @account, d, (err, results)->
        expect(err).to.be.undefined
        expect(results).to.deep.equal(expected)
        done()
