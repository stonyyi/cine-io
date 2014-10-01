Show = testApi Cine.api('stats/show')
User = Cine.server_model('user')
Account = Cine.server_model('account')
CalculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
calculateAndSaveUsageStats = Cine.server_lib("stats/calculate_and_save_usage_stats")
moment = require('moment')
_ = require('underscore')

describe 'Stats#Show', ->
  testApi.requiresSiteAdmin Show

  beforeEach (done)->
    @siteAdmin = new User(isSiteAdmin: true)
    @siteAdmin.save done

  beforeEach (done)->
    @account1 = new Account name: "account1 name"
    @account1.save done

  beforeEach (done)->
    @account2 = new Account name: "account2 name"
    @account2.save done

  beforeEach (done)->
    @account3 = new Account name: "account3 name"
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

  beforeEach calculateAndSaveUsageStats

  assertCorrectResponse = (response)->
    expectedResult = {}
    expectedResult[@account1._id.toString()] = {name: 'account1 name', usage: 12345}
    expectedResult[@account2._id.toString()] = {name: 'account2 name', usage: 54321}
    expectedResult[@account3._id.toString()] = {name: 'account3 name', usage: 12121}

    expect(response).to.have.length(3)

    _.each response, (accountUsageReport)->
      expected = expectedResult[accountUsageReport._id.toString()]
      expect(accountUsageReport.name).to.equal(expected.name)
      expect(accountUsageReport.usage).to.equal(expected.usage)

  it 'returns the usage stats', (done)->
    params = {id: 'some-stats'}
    session = user: @siteAdmin
    callback = (err, response)=>
      expect(err).to.be.null
      expect(response.id).to.equal('some-stats')
      usageMonth = moment(new Date).format("MMM YYYY")
      expect(response.usageMonthName).to.equal(usageMonth)
      assertCorrectResponse.call(this, response.usage)
      done()

    Show params, session, callback
