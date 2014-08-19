User = Cine.server_model('user')
Account = Cine.server_model('account')
Show = testApi Cine.api('users/show')

describe 'Users#Show', ->
  testApi.requresLoggedIn Show

  beforeEach (done)->
    @account = new Account(name: 'account name yo', tempPlan: 'free')
    @account.save done

  beforeEach (done)->
    @user = new User name: 'Mah name', email: 'mah@example.com', plan: @account.tempPlan
    @user._accounts.push @account._id
    @user.save done

  it 'returns the user when given a masterKey', (done)->
    params = { masterKey: @user.masterKey }
    callback = (err, response, options)=>
      expect(err).to.equal(null)
      expect(response.email).to.equal('mah@example.com')
      expect(response.masterKey).to.equal(@user.masterKey)
      done()

    Show params, callback

  it 'returns the user when loggedIn', (done)->
    params = { sessionUserId: @user._id }
    callback = (err, response, options)=>
      expect(err).to.equal(null)
      expect(response.email).to.equal('mah@example.com')
      expect(response.masterKey).to.equal(@user.masterKey)
      expect(response.accounts).to.have.length(1)
      expect(response.accounts[0].name).to.equal('account name yo')
      done()

    Show params, callback
