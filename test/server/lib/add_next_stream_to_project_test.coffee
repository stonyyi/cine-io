addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
Project = Cine.server_model('project')

describe 'addNextStreamToProject', ->
  beforeEach (done)->
    @project = new Project name: 'some project', plan: 'free'
    @project.save done

  beforeEach (done)->
    @stream = new EdgecastStream(instanceName: 'cines')
    @stream.save done

  stubEdgecast()

  describe 'free plan', ->
    beforeEach (done)->
      @project.plan = 'free'
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
      @project.plan = 'enterprise'
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
