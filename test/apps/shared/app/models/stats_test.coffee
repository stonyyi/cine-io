basicModel = Cine.require 'test/helpers/basic_model'
basicModel('stats', urlAttributes: ['id'], id: 'id')
Stats = Cine.model('stats')
Account = Cine.model('account')

describe 'Stats', ->

  describe 'getSortedUsage', ->
    beforeEach ->
      @account1 = id: "id1", name: "1 name", usage: {bandwidth: 123, storage: 999}
      @account2 = id: "id2", name: "2 name", usage: {bandwidth: 789, storage: 777}
      @account3 = id: "id3", name: "3 name", usage: {bandwidth: 456, storage: 888}

    it 'returns accounts sorted by bandwidth', ->
      stats = new Stats usage: [@account1, @account2, @account3]
      accounts = stats.getSortedUsage('bandwidth')
      expect(accounts).to.have.length(3)
      expect(accounts[0]).to.be.an.instanceof(Account)
      expect(accounts[0].attributes).to.deep.equal(@account2)
      expect(accounts[1].attributes).to.deep.equal(@account3)
      expect(accounts[2].attributes).to.deep.equal(@account1)

    it 'returns accounts sorted by storage', ->
      stats = new Stats usage: [@account1, @account2, @account3]
      accounts = stats.getSortedUsage('storage')
      expect(accounts).to.have.length(3)
      expect(accounts[0]).to.be.an.instanceof(Account)
      expect(accounts[0].attributes).to.deep.equal(@account1)
      expect(accounts[1].attributes).to.deep.equal(@account3)
      expect(accounts[2].attributes).to.deep.equal(@account2)
