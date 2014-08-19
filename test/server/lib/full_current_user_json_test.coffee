fullCurrentUserJson = Cine.server_lib('full_current_user_json')
User = Cine.server_model('user')
Account = Cine.server_model('account')

describe 'fullCurrentUserJson', ->

  beforeEach (done)->
    @account = new Account(name: 'account name', tempPlan: 'solo', masterKey: '1mkey')
    @account.save done

  beforeEach (done)->
    @account2 = new Account(name: 'second account', tempPlan: 'solo', masterKey: '2mkey')
    @account2.save done

  beforeEach (done)->
    @user = new User(name: 'my name', email: 'some email', plan: @account.tempPlan)
    @user.save done

  describe 'without accounts', ->

    beforeEach (done)->
      fullCurrentUserJson @user, (err, @userJson)=>
        done(err)

    it 'returns the user details', ->
      expect(@userJson.id.toString()).to.equal(@user._id.toString())
      expect(@userJson.name).to.equal('my name')
      expect(@userJson.email).to.equal('some email')
      expect(@userJson.accounts).to.be.undefined

  describe 'with accounts', ->
    beforeEach (done)->
      @user._accounts.push @account._id
      @user._accounts.push @account2._id
      @user.save done

    beforeEach (done)->
      fullCurrentUserJson @user, (err, @userJson)=>
        done(err)

    it 'returns the user details', ->
      expect(@userJson.id.toString()).to.equal(@user._id.toString())
      expect(@userJson.name).to.equal('my name')
      expect(@userJson.email).to.equal('some email')
      expect(@userJson.accounts).to.have.length(2)

    it 'returns the accounts details', ->
      firstAccount = @userJson.accounts[0]
      expect(firstAccount._id.toString()).to.equal(@account._id.toString())
      expect(firstAccount.name).to.equal('account name')
      expect(firstAccount.masterKey).to.equal('1mkey')
      secondAccount = @userJson.accounts[1]
      expect(secondAccount._id.toString()).to.equal(@account2._id.toString())
      expect(secondAccount.name).to.equal('second account')
      expect(secondAccount.masterKey).to.equal('2mkey')
