basicModel = Cine.require 'test/helpers/basic_model'
basicModel('account', urlAttributes: ['masterKey'], id: 'masterKey')
Account = Cine.model('account')

describe 'Account', ->

  describe '.plans', ->
    it 'has plans', ->
      expect(Account.plans).to.deep.equal(['free', 'solo', 'basic', 'pro'])

  describe '#isHeroku', ->
    it 'is true with heroku', ->
      account = new Account(provider: "heroku")
      expect(account.isHeroku()).to.be.true

    it 'is false without heroku', ->
      account = new Account(provider: "cine.io")
      expect(account.isHeroku()).to.be.false

  describe.only 'needsCreditCard', ->
    it 'returns true for an account on a paid plan without a credit card', ->
      account = new Account(plans: ['pro'], provider: 'cine.io')
      expect(account.needsCreditCard()).to.be.true

    it 'returns true for an account with at least one paid plan without a credit card', ->
      account = new Account(plans: ['free', 'pro'], provider: 'cine.io')
      expect(account.needsCreditCard()).to.be.true

    it 'returns false for an account on a free plan without a credit card', ->
      account = new Account(plans: ['free'], provider: 'cine.io')
      expect(account.needsCreditCard()).to.be.false

    it 'returns false for an account on a paid plan with a credit card', ->
      account = new Account(plans: ['pro'], provider: 'cine.io', stripeCard: {last4: '4242'})
      expect(account.needsCreditCard()).to.be.false
    it 'returns false for an account on a paid plan without a credit card on a different provider', ->
      account = new Account(plans: ['pro'], provider: 'heroku')
      expect(account.needsCreditCard()).to.be.false

  describe '#isAppdirect', ->
    it 'is true with appdirect', ->
      account = new Account(provider: 'appdirect')
      expect(account.isAppdirect()).to.be.true

    it 'is false without appdirect', ->
      account = new Account(provider: 'cine.io')
      expect(account.isAppdirect()).to.be.false
