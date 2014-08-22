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
