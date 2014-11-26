basicModel = Cine.require 'test/helpers/basic_model'
basicModel('stats', urlAttributes: ['id'], id: 'id')
Stats = Cine.model('stats')
Account = Cine.model('account')

describe 'Stats', ->

  beforeEach ->
    @account1 = id: "id1", name: "1 name", usage: {bandwidth: 123, storage: 999}
    @account2 = id: "id2", name: "2 name", usage: {bandwidth: 789, storage: 777}
    @account3 = id: "id3", name: "3 name", usage: {bandwidth: 456, storage: 888}
    attributes = {usage:{}}
    attributes.usage["usage-2014-08"] = [@account1, @account2, @account3]
    attributes.usage["usage-2014-09"] = [@account3]
    @stats = new Stats attributes

  describe 'getUsageMonths', ->
    it 'returns the sorted months', ->
      months = @stats.getUsageMonths('bandwidth')
      expect(months).to.deep.equal(['2014-09', '2014-08'])

  describe 'getSortedUsage', ->
    it 'returns accounts sorted by bandwidth', ->
      accounts = @stats.getSortedUsage('bandwidth', '2014-08')
      expect(accounts).to.have.length(3)
      expect(accounts[0]).to.be.an.instanceof(Account)
      expect(accounts[0].attributes).to.deep.equal(@account2)
      expect(accounts[1].attributes).to.deep.equal(@account3)
      expect(accounts[2].attributes).to.deep.equal(@account1)

    it 'returns accounts sorted by storage', ->
      accounts = @stats.getSortedUsage('storage', '2014-08')
      expect(accounts).to.have.length(3)
      expect(accounts[0]).to.be.an.instanceof(Account)
      expect(accounts[0].attributes).to.deep.equal(@account1)
      expect(accounts[1].attributes).to.deep.equal(@account3)
      expect(accounts[2].attributes).to.deep.equal(@account2)

  describe 'total', ->
    it 'returns the total bandwidth', ->
      expect(@stats.total('bandwidth', '2014-08')).to.equal(1368)
      expect(@stats.total('bandwidth', '2014-09')).to.equal(456)

    it 'returns the total storage', ->
      expect(@stats.total('storage', '2014-08')).to.equal(2664)
      expect(@stats.total('storage', '2014-09')).to.equal(888)
