basicModel = Cine.require 'test/helpers/basic_model'
basicModel('user')
User = Cine.model('user')

describe 'User', ->
  describe '#isLoggedIn', ->

    it 'is true for users an id', ->
      expect((new User(id: 'my id')).isLoggedIn()).to.be.true

    it 'is false for users without an id', ->
      expect((new User).isLoggedIn()).to.be.false

  it 'has plans', ->
    expect(User.plans).to.deep.equal(['free', 'solo', 'startup', 'enterprise'])
