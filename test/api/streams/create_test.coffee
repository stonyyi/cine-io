Organization = Cine.model('organization')
EdgecastStream = Cine.model('edgecast_stream')
Create = testApi Cine.api('streams/create')

describe 'EdgecastStreams#Create', ->
  testApi.requresApiKey Create

  beforeEach (done)->
    @org = new Organization(name: 'my org')
    @org.save done
  it 'can error with no available edgecast stream', (done)->
    params = apiKey: @org.apiKey
    Create params, (err, response, options)->
      expect(err).to.equal('Next stream not available, please try again later')
      expect(response).to.be.null
      expect(options.status).to.equal(400)
      done()
  describe 'with available stream', (done)->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'abcd')
      @stream.save done

    it 'returns an edgecast stream', (done)->
      params = apiKey: @org.apiKey
      Create params, (err, response, options)->
        expect(err).to.be.null
        expect(response.instanceName).to.equal('abcd')
        expect(options).to.be.undefined
        done()

    it 'assigns the stream to the organization', (done)->
      params = apiKey: @org.apiKey
      Create params, (err, response, options)=>
        EdgecastStream.findById @stream._id, (err, stream)=>
          expect(err).to.be.null
          expect(stream._organization.toString()).to.equal(@org._id.toString())
          done()
