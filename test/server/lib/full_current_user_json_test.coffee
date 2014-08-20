fullCurrentUserJson = Cine.server_lib('full_current_user_json')
User = Cine.server_model('user')
Account = Cine.server_model('account')

describe 'fullCurrentUserJson', ->

  beforeEach (done)->
    cards = [
      {stripeCardId: '123', last4: 'the last 4', brand: 'visa', exp_month: '01', exp_year: '2013'},
      {stripeCardId: '456', last4: 'these last 4', brand: 'master', exp_month: '12', exp_year: '2014'}
    ]
    @account = new Account(name: 'account name', tempPlan: 'solo', masterKey: '1mkey', stripeCustomer: {stripeCustomerId: 'cus_2ghmxawfvEwXkw', cards: cards})
    @account.save done

  beforeEach (done)->
    @account2 = new Account(name: 'second account', tempPlan: 'starter', masterKey: '2mkey')
    @account2.save done

  beforeEach (done)->
    @user = new User(name: 'my name', email: 'some email')
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
      expect(firstAccount.id.toString()).to.equal(@account._id.toString())
      expect(firstAccount.name).to.equal('account name')
      expect(firstAccount.masterKey).to.equal('1mkey')
      expect(firstAccount.tempPlan).to.equal('solo')
      secondAccount = @userJson.accounts[1]
      expect(secondAccount.id.toString()).to.equal(@account2._id.toString())
      expect(secondAccount.name).to.equal('second account')
      expect(secondAccount.masterKey).to.equal('2mkey')
      expect(secondAccount.tempPlan).to.equal('starter')

    it 'returns the accounts stripe details', ->
      firstAccount = @userJson.accounts[0]
      expect(firstAccount.stripeCustomer).to.be.undefined
      expect(firstAccount.stripeCard.id.toString()).to.equal(@account.stripeCustomer.cards[0]._id.toString())
      expect(firstAccount.stripeCard.last4).to.equal('the last 4')
      expect(firstAccount.stripeCard.brand).to.equal('visa')
      expect(firstAccount.stripeCard.exp_month).to.equal(1)
      expect(firstAccount.stripeCard.exp_year).to.equal(2013)
      secondAccount = @userJson.accounts[1]
      expect(secondAccount.stripeCustomer).to.be.undefined
      expect(secondAccount.stripeCard).to.be.undefined
