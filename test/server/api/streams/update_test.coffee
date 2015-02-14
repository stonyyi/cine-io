EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
Update = testApi Cine.api('streams/update')

describe 'Streams#Update', ->
  testApi.requresApiKey Update, 'secret'

  beforeEach (done)->
    @project = new Project(name: 'my project', streamsCount: 3)
    @project.save done

  beforeEach (done)->
    @projectStream = new EdgecastStream
      instanceName: 'cines'
      _project: @project._id
      streamName: 'this stream'
    @projectStream.save done

  describe 'failure', ->
    it 'requires an id', (done)->
      params = secretKey: @project.secretKey
      Update params, (err, response, options)->
        expect(err).to.equal('id required')
        expect(response).to.be.null
        expect(options).to.deep.equal(status: 400)
        done()

  it 'sets the name on the stream', (done)->
    params = secretKey: @project.secretKey, id: @projectStream._id, name: 'new name'
    Update params, (err, response, options)=>
      expect(err).to.be.null
      expect(response.id).to.equal(@projectStream._id.toString())
      expect(response.name).to.equal('new name')
      EdgecastStream.findById @projectStream._id, (err, stream)->
        expect(stream.name).to.be.equal('new name')
        done()

  it 'sets record on the stream', (done)->
    params = secretKey: @project.secretKey, id: @projectStream._id, record: 'true'
    Update params, (err, response, options)=>
      expect(err).to.be.null
      expect(response.id).to.equal(@projectStream._id.toString())
      expect(response.record).to.be.true
      EdgecastStream.findById @projectStream._id, (err, stream)->
        expect(response.record).to.be.true
        done()

  it 'can change record from true to false on the stream', (done)->
    @projectStream.record = true
    @projectStream.save (err, stream)=>
      expect(err).to.be.null
      params = secretKey: @project.secretKey, id: @projectStream._id, record: 'false'
      Update params, (err, response, options)=>
        expect(err).to.be.null
        expect(response.id).to.equal(@projectStream._id.toString())
        expect(response.record).to.be.false
        EdgecastStream.findById @projectStream._id, (err, stream)->
          expect(response.record).to.be.false
          done()
