basicModel = Cine.require 'test/helpers/basic_model'
basicModel('user')
User = Cine.model('user')

describe 'User', ->
  describe '#isLoggedIn', ->

    it 'is true for users an id', ->
      expect((new User(id: 'my id')).isLoggedIn()).to.be.true

    it 'is false for users without an id', ->
      expect((new User).isLoggedIn()).to.be.false

  describe 'createdAt', ->
    it 'returns a date', ->
      u = new User(createdAt: (new Date).toISOString())
      expect(u.createdAt()).to.be.instanceOf(Date)

    it 'returns null when unavailable', ->
      e = new User()
      expect(e.createdAt()).to.be.null

  describe 'isNew', ->
    it 'returns false for old users', ->
      d = new Date
      d.setHours(d.getHours() - 1)
      c = new User(createdAt: d.toISOString())
      expect(c.isNew()).to.be.false

    it 'returns true for new users', ->
      d = new Date
      c = new User(createdAt: d.toISOString())
      expect(c.isNew()).to.be.true

    it 'returns true for new users created in the last two minutes', ->
      d = new Date
      d.setMinutes(d.getMinutes() + 1)
      d.setSeconds(d.getSeconds() + 27)
      c = new User(createdAt: d.toISOString())
      expect(c.isNew()).to.be.true

  describe 'accounts', ->
    it 'is tested'
