fullCurrentUserJson = Cine.server_lib('full_current_user_json')
User = Cine.server_model('user')
Account = Cine.server_model('account')

describe 'fullCurrentUserJson', ->

  beforeEach (done)->
    cards = [
      {stripeCardId: '123', last4: 'the last 4', brand: 'visa', exp_month: '01', exp_year: '2013'},
      {stripeCardId: '456', last4: 'these last 4', brand: 'master', exp_month: '12', exp_year: '2014'}
    ]
    @account = new Account(name: 'account name', plans: ['solo'], herokuId: 'my heroku id', masterKey: '1mkey', billingProvider: 'heroku', stripeCustomer: {stripeCustomerId: 'cus_2ghmxawfvEwXkw', cards: cards})
    @account.save done

  beforeEach (done)->
    @account2 = new Account(name: 'second account', plans: ['basic', 'pro'], masterKey: '2mkey', billingProvider: 'cine.io')
    @account2.save done

  beforeEach (done)->
    @account3 = new Account(name: 'third account', plans: [], masterKey: '4mkey', billingProvider: 'appdirect', appdirectData: {marketplace: {baseUrl: 'the-mplace-base-url'}})
    @account3.save done

  beforeEach (done)->
    @account4 = new Account(name: 'forth account', plans: [], masterKey: '4mkey', billingProvider: 'cine.io', deletedAt: new Date)
    @account4.save done

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
      @user._accounts.push @account3._id
      @user._accounts.push @account4._id
      @user.save done

    beforeEach (done)->
      fullCurrentUserJson @user, (err, @userJson)=>
        done(err)

    it 'returns the user details', ->
      expect(@userJson.id.toString()).to.equal(@user._id.toString())
      expect(@userJson.name).to.equal('my name')
      expect(@userJson.email).to.equal('some email')
      expect(@userJson.accounts).to.have.length(3)
      expect(@userJson._accounts).to.be.undefined

    it 'returns the accounts details', ->
      firstAccount = @userJson.accounts[0]
      expect(firstAccount.id.toString()).to.equal(@account._id.toString())
      expect(firstAccount.name).to.equal('account name')
      expect(firstAccount.masterKey).to.equal('1mkey')
      expect(firstAccount.plans).have.length(1)
      expect(firstAccount.plans[0]).to.equal('solo')
      expect(firstAccount.herokuId).to.equal('my heroku id')
      expect(firstAccount.provider).to.equal('heroku')

      secondAccount = @userJson.accounts[1]
      expect(secondAccount.id.toString()).to.equal(@account2._id.toString())
      expect(secondAccount.name).to.equal('second account')
      expect(secondAccount.masterKey).to.equal('2mkey')
      expect(secondAccount.plans).have.length(2)
      expect(secondAccount.plans[0]).to.equal('basic')
      expect(secondAccount.plans[1]).to.equal('pro')
      expect(secondAccount.provider).to.equal('cine.io')
      expect(secondAccount.herokuId).to.be.undefined

      thirdAccount = @userJson.accounts[2]
      expect(thirdAccount.id.toString()).to.equal(@account3._id.toString())
      expect(thirdAccount.plans).have.length(0)
      expect(thirdAccount.provider).to.equal('appdirect')
      expect(thirdAccount.appdirect).to.deep.equal(baseUrl: 'the-mplace-base-url')
      expect(thirdAccount.herokuId).to.be.undefined

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
      thirdAccount = @userJson.accounts[2]
      expect(thirdAccount.stripeCustomer).to.be.undefined
      expect(thirdAccount.stripeCard).to.be.undefined
