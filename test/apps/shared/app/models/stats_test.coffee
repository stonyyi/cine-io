basicModel = Cine.require 'test/helpers/basic_model'
basicModel('stats', urlAttributes: ['id'], id: 'id')
Stats = Cine.model('stats')
Account = Cine.model('account')

describe 'Stats', ->

  describe 'getSortedUsage', ->
    it 'returns accounts sorted by usage', ->
      account1 = id: "id1", name: "1 name", usage: 123
      account2 = id: "id2", name: "2 name", usage: 789
      account3 = id: "id3", name: "3 name", usage: 456

      stats = new Stats usage: [account1, account2, account3]
      accounts = stats.getSortedUsage()
      expect(accounts).to.have.length(3)
      expect(accounts[0]).to.be.an.instanceof(Account)
      expect(accounts[0].attributes).to.deep.equal(account2)
      expect(accounts[1].attributes).to.deep.equal(account3)
      expect(accounts[2].attributes).to.deep.equal(account1)
