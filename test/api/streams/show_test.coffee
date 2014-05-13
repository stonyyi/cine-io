Project = Cine.model('project')
EdgecastStream = Cine.model('edgecast_stream')
Show = testApi Cine.api('streams/show')

describe 'EdgecastStreams#Show', ->
  testApi.requresApiKey Show

  beforeEach (done)->
    @project = new Project(name: 'my project')
    @project.save done

  beforeEach (done)->
    @projectStream = new EdgecastStream(instanceName: 'some instance', _project: @project._id)
    @projectStream.save done

  beforeEach (done)->
    @notProjectStream = new EdgecastStream(instanceName: 'some instance')
    @notProjectStream.save done

  describe 'failure', ->
    it 'requires an id', (done)->
      params = apiKey: @project.apiKey
      Show params, (err, response, options)->
        expect(err).to.equal('id required')
        expect(response).to.be.null
        expect(options.status).to.equal(400)
        done()

    it 'will not return a stream not owned by a different project', (done)->
      params = apiKey: @project.apiKey, id: @notProjectStream._id
      Show params, (err, response, options)->
        expect(err).to.equal('stream not found')
        expect(response).to.be.null
        expect(options.status).to.equal(404)
        done()

  it 'will return a stream owned by the project', (done)->
    params = apiKey: @project.apiKey, id: @projectStream._id
    Show params, (err, response, options)=>
      expect(err).to.be.null
      expect(response._id.toString()).to.equal(@projectStream._id.toString())
      expect(response.instanceName).to.equal('some instance')
      done()
