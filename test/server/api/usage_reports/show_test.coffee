Account = Cine.server_model('account')
ShowUsageReports = testApi Cine.api('usage_reports/show')

describe 'ShowUsageReports', ->
  testApi.requiresMasterKey ShowUsageReports

  beforeEach (done)->
    @account = new Account masterKey: 'dat mk', plans: ['free']
    @account.save done

  it 'calculates a usage report', (done)->
    params = {masterKey: 'dat mk'}
    callback = (err, response)->
      expect(err).to.be.null
      expectedResponse =
        "2014-5": 0,
        "2014-6": 0,
        "2014-7": 0,
        "masterKey": 'dat mk'
      expect(response).to.deep.equal(expectedResponse)
      done()

    ShowUsageReports params, callback
