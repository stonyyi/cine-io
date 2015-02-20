addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
Project = Cine.server_model('project')
Account = Cine.server_model('account')

describe 'addNextStreamToProject', ->

  beforeEach (done)->
    @account = new Account billingProvider: 'cine.io', name: 'some account', productPlans: {broadcast: ['free']}
    @account.save done

  beforeEach (done)->
    @project = new Project name: 'some project', _account: @account._id
    @project.save done

  beforeEach (done)->
    @notOwnedByAccount = new Project name: 'some project', streamsCount: 123
    @notOwnedByAccount.save done

  beforeEach (done)->
    @stream = new EdgecastStream(instanceName: 'cines', streamName: 'this stream')
    @stream.save done

  stubEdgecast()

  describe 'free plan', ->
    beforeEach (done)->
      @account.productPlans = {broadcast: ['free']}
      @account.save done

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

      describe 'when the previous stream is deleted', ->
        beforeEach (done)->
          @stream.deletedAt = new Date
          @stream.save done

        beforeEach (done)->
          @stream2 = new EdgecastStream(instanceName: 'cines', streamName: 'this stream2', _project: @project)
          @stream2.save done

        it 'returns the one allocated stream', (done)->
          addNextStreamToProject @project, (err, stream)=>
            expect(err).to.be.null
            expect(stream._id.toString()).to.equal(@stream2._id.toString())
            done()

  describe 'pro plan', ->
    beforeEach (done)->
      @account.productPlans = {broadcast: ['pro']}
      @account.save done

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

    it 'adds a name', (done)->
      addNextStreamToProject @project, name: "my stream", (err, stream)=>
        expect(err).to.be.null
        expect(stream.id).to.equal(@stream._id.toString())
        expect(stream.name).to.equal("my stream")
        EdgecastStream.findById stream.id, (err, streamFromDb)=>
          expect(err).to.be.null
          expect(streamFromDb._project.toString()).to.equal(@project._id.toString())
          expect(streamFromDb.name).to.equal("my stream")
          done()

    it 'updates the streamsCount', (done)->
      addNextStreamToProject @project, (err, stream)=>
        expect(err).to.be.null
        Project.findById @project._id, (err, projectFromDb)->
          expect(err).to.be.null
          expect(projectFromDb.streamsCount).to.equal(2930)
          done()
