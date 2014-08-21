basicModel = Cine.require 'test/helpers/basic_model'
basicModel('account', urlAttributes: ['masterKey'], id: 'masterKey')
Account = Cine.model('account')

describe 'Account', ->

  describe '#isHeroku', ->
    it 'is true with a herokuId', ->
      account = new Account(herokuId: 'the id')
      expect(account.isHeroku()).to.be.true

    it 'is false without a herokuId', ->
      account = new Account(herokuId: null)
      expect(account.isHeroku()).to.be.false
