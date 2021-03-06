Project = Cine.server_model('project')
TurnUser = Cine.server_model('turn_user')
EdgecastStream = Cine.server_model('edgecast_stream')
Delete = testApi Cine.api('projects/delete')
createTurnUserForProject = Cine.server_lib('coturn/create_turn_user_for_project')

describe 'Projects#Delete', ->
  testApi.requresApiKey Delete, 'secret'

  beforeEach (done)->
    @project = new Project(name: 'my project', streamsCount: 1)
    @project.save done

  beforeEach (done)->
    @stream1 = new EdgecastStream(_project: @project, streamName: 'random-1')
    @stream1.save done

  beforeEach (done)->
    @stream2 = new EdgecastStream(_project: @project, streamName: 'random-2')
    @stream2.save done

  beforeEach (done)->
    @notProjectStream = new EdgecastStream streamName: 'random-3'
    @notProjectStream.save done

  beforeEach (done)->
    createTurnUserForProject @project, done

  it 'adds deletedAt to the project', (done)->
    params = secretKey: @project.secretKey
    Delete params, (err, response, options)=>
      expect(err).to.be.null
      expect(response.id).to.equal(@project._id.toString())
      expect(response.deletedAt).to.be.instanceOf(Date)
      Project.findById @project._id, (err, project)->
        expect(project.deletedAt).to.be.instanceOf(Date)
        done()

  it 'deletes the turn user', (done)->
    TurnUser.findOne _project: @project._id, (err, tu)=>
      expect(err).to.be.null
      expect(tu).to.be.ok
      params = secretKey: @project.secretKey
      Delete params, (err, response, options)=>
        TurnUser.findOne _project: @project._id, (err, tu)->
          expect(err).to.be.null
          expect(tu).to.be.null
          done()

  it 'deletes all the associated streams', (done)->
    params = secretKey: @project.secretKey
    Delete params, (err, response, options)=>
      expect(err).to.be.null
      EdgecastStream.findById @stream1._id, (err, stream1)=>
        expect(err).to.be.null
        expect(stream1.deletedAt).to.be.instanceOf(Date)
        EdgecastStream.findById @stream2._id, (err, stream2)=>
          expect(err).to.be.null
          expect(stream2.deletedAt).to.be.instanceOf(Date)
          EdgecastStream.findById @notProjectStream._id, (err, notProjectStream)->
            expect(err).to.be.null
            expect(notProjectStream.deletedAt).to.be.undefined
            done()
