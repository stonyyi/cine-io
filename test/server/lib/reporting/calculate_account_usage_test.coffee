calculateAccountUsage = Cine.server_lib("reporting/calculate_account_usage")
Account = Cine.server_model('account')
CalculateAccountBandwidth = Cine.server_lib('reporting/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/calculate_account_storage')

describe 'calculateAccountUsage', ->
  beforeEach (done)->
    @account = new Account billingProvider: 'cine.io'
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
    @fakeStorageThisMonth = {}
    @fakeStorageThisMonth[@account._id.toString()] = 111111

    @fakeStorageByMonth = {}
    @fakeStorageByMonth[@account._id.toString()] = 2222222

    @storageStub = sinon.stub CalculateAccountStorage, 'byMonth', (account, month, callback)=>
      resource = if month.getYear() == (new Date).getYear() then @fakeStorageThisMonth else @fakeStorageByMonth
      callback(null, resource[account._id.toString()])

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
        storage: 2222222

      calculateAccountUsage.byMonth @account, d, (err, results)->
        expect(err).to.be.undefined
        expect(results).to.deep.equal(expected)
        done()
