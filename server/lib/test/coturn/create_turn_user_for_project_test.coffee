TurnUser = Cine.server_model('turn_user')
Project = Cine.server_model('project')
createTurnUserForProject = Cine.server_lib('coturn/create_turn_user_for_project')

describe 'createTurnUserForProject', ->
  beforeEach (done)->
    @project = new Project publicKey: 'the pub key', turnPassword: 'the turn pass'
    @project.save done
  it 'requires a turnPassword', (done)->
    createTurnUserForProject new Project,  (err)->
      expect(err).to.equal("no turnPassword set")
      done()

  it 'creates a turn user', (done)->
    createTurnUserForProject @project,  (err)=>
      expect(err).to.be.null
      TurnUser.findOne _project: @project._id, (err, turnUser)->
        expect(turnUser.name).to.equal('the pub key')
        expect(turnUser.realm).to.equal('cine.io')
        expect(turnUser.hmackey).to.equal('2beeb45311dc65b7dab12865c27c1d84')
        done()
