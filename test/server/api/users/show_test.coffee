User = Cine.server_model('user')
ShowUser = testApi Cine.api('users/show')

describe 'Users#show', ->

  beforeEach (done)->
    @user = new User name: 'Mah name', email: 'mah@example.com', plan: 'free'
    @user.save done

  it 'requires a masterKey', (done)->
    params = {}
    callback = (err, response)->
      expect(err).to.contain("master token not supplied")
      expect(response).to.equal(null)
      done()

    ShowUser params, callback

  it 'returns the user when given a masterKey', (done)->
    params = { masterKey: @user.masterKey }
    callback = (err, response, options)->
      expect(err).to.equal(null)
      expect(response.email).to.equal('mah@example.com')
      expect(response.masterKey).not.to.equal(null)
      done()

    ShowUser params, callback
