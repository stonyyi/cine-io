Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
Create = testApi Cine.api('streams/create')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'

describe 'EdgecastStreams#Create', ->
  testApi.requresApiKey Create

  beforeEach (done)->
    @project = new Project(name: 'my project')
    @project.save done

  it 'can error with no available edgecast stream', (done)->
    params = apiKey: @project.apiKey
    Create params, (err, response, options)->
      expect(err).to.equal('Next stream not available, please try again later')
      expect(response).to.be.null
      expect(options.status).to.equal(400)
      done()

  describe 'with available stream', (done)->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'abcd')
      @stream.save done

    stubEdgecast()

    it 'returns an edgecast stream', (done)->
      params = apiKey: @project.apiKey
      Create params, (err, response, options)->
        expect(err).to.be.null
        expect(response.instanceName).to.equal('abcd')
        expect(options).to.be.undefined
        done()

    it 'assigns the stream to the project', (done)->
      params = apiKey: @project.apiKey
      Create params, (err, response, options)=>
        EdgecastStream.findById @stream._id, (err, stream)=>
          expect(err).to.be.null
          expect(stream._project.toString()).to.equal(@project._id.toString())
          done()
