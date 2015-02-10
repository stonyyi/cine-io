Realm = Cine.server_model('realm')

describe 'Realm', ->
  it 'has a hardcoded HARD_CODED_REALM_SAME_AS_TURN_SERVER', ->
    expect(Realm.HARD_CODED_REALM_SAME_AS_TURN_SERVER).to.equal('cine.io')
  describe 'realm', ->
    it 'has a realm', (done)->
      realm = new Realm(realm: 'some realm')
      realm.save (err)->
        expect(err).to.be.null
        expect(realm.realm).to.equal('some realm')
        done()
