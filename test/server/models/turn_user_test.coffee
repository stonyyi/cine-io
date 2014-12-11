TurnUser = Cine.server_model('turn_user')

describe 'TurnUser', ->

  describe 'realm', ->
    it 'has a realm of cine.io', (done)->
      tu = new TurnUser(name: 'some name')
      tu.save (err)->
        expect(err).to.be.null
        expect(tu.realm).to.equal('cine.io')
        done()
