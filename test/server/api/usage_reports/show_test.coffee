User = Cine.server_model('user')
ShowUsageReports = testApi Cine.api('usage_reports/show')

describe 'ShowUsageReports', ->

  beforeEach (done)->
    @user = new User name: 'Mah name', email: 'mah@example.com', plan: 'free'
    @user.save done

  it 'requires a logged in user or masterKey', (done)->
    params = {}
    callback = (err, response)->
      expect(err).to.contain("not logged in or masterKey not supplied")
      expect(response).to.equal(null)
      done()

    ShowUsageReports params, callback

  it 'calculates a usage report', (done)->
    params = {sessionUserId: @user._id}
    callback = (err, response)->
      expect(err).to.be.null
      expect(response).to.deep.equal(id: @user.masterKey, monthlyBytes: 0)
      done()

    ShowUsageReports params, callback
