addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
Project = Cine.server_model('project')
User = Cine.server_model('user')

describe 'addNextStreamToProject', ->
  beforeEach (done)->
    @project = new Project name: 'some project'
    @project.save done

  beforeEach (done)->
    @notOwnedByUser = new Project name: 'some project', streamsCount: 123
    @notOwnedByUser.save done

  beforeEach (done)->
    @user = new User name: 'some user', email: 'my email', plan: 'free'
    @user.permissions.push objectId: @project._id, objectName: 'Project'
    @user.save done

  beforeEach (done)->
    @stream = new EdgecastStream(instanceName: 'cines')
    @stream.save done

  stubEdgecast()

  describe 'free plan', ->
    beforeEach (done)->
      @user.plan = 'free'
      @user.save done

    it 'adds a single stream', (done)->
      expect(@stream.assignedAt).to.be.undefined
      expect(@stream._project).to.be.undefined
      addNextStreamToProject @project, (err, stream)=>
        expect(err).to.be.null
        expect(stream.id).to.equal(@stream._id.toString())
        expect(stream.assignedAt).to.be.instanceOf(Date)
        EdgecastStream.findById stream.id, (err, streamFromDb)=>
          expect(err).to.be.null
          expect(streamFromDb.assignedAt).to.be.instanceOf(Date)
          expect(streamFromDb._project.toString()).to.equal(@project._id.toString())
          done()

    it 'updates the streamsCount', (done)->
      addNextStreamToProject @project, (err, stream)=>
        expect(err).to.be.null
        Project.findById @project._id, (err, projectFromDb)->
          expect(err).to.be.null
          expect(projectFromDb.streamsCount).to.equal(1)
          done()

    describe 'with maximum amount', ->
      beforeEach (done)->
        addNextStreamToProject @project, done

      it 'returns the one allocated stream', (done)->
        addNextStreamToProject @project, (err, stream)=>
          expect(err).to.be.null
          expect(stream._id.toString()).to.equal(@stream._id.toString())
          done()

  describe 'enterprise plan', ->
    beforeEach (done)->
      @user.plan = 'enterprise'
      @user.save done

    beforeEach (done)->
      @project.streamsCount = 2929
      @project.save done

    it 'adds a single stream', (done)->
      addNextStreamToProject @project, (err, stream)=>
        expect(err).to.be.null
        expect(stream.id).to.equal(@stream._id.toString())
        EdgecastStream.findById stream.id, (err, streamFromDb)=>
          expect(err).to.be.null
          expect(streamFromDb._project.toString()).to.equal(@project._id.toString())
          done()

    it 'updates the streamsCount', (done)->
      addNextStreamToProject @project, (err, stream)=>
        expect(err).to.be.null
        Project.findById @project._id, (err, projectFromDb)->
          expect(err).to.be.null
          expect(projectFromDb.streamsCount).to.equal(2930)
          done()
