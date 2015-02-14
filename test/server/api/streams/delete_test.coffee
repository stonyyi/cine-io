EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
Delete = testApi Cine.api('streams/delete')

describe 'Streams#Delete', ->
  testApi.requresApiKey Delete, 'secret'

  beforeEach (done)->
    @project = new Project(name: 'my project', streamsCount: 3)
    @project.save done

  beforeEach (done)->
    @projectStream = new EdgecastStream
      instanceName: 'cines'
      streamName: 'this stream'
      _project: @project._id
    @projectStream.save done

  describe 'failure', ->
    it 'requires an id', (done)->
      params = secretKey: @project.secretKey
      Delete params, (err, response, options)->
        expect(err).to.equal('id required')
        expect(response).to.be.null
        expect(options).to.deep.equal(status: 400)
        done()

  it 'adds deletedAt to the stream', (done)->
    params = secretKey: @project.secretKey, id: @projectStream._id
    Delete params, (err, response, options)=>
      expect(err).to.be.null
      expect(response.id).to.equal(@projectStream._id.toString())
      expect(response.deletedAt).to.be.instanceOf(Date)
      EdgecastStream.findById @projectStream._id, (err, stream)->
        expect(stream.deletedAt).to.be.instanceOf(Date)
        done()

  it 'reduces the project streams counter cache by 1', (done)->
    params = secretKey: @project.secretKey, id: @projectStream._id
    expect(@project.streamsCount).to.equal(3)
    Delete params, (err, response, options)=>
      Project.findById @project._id, (err, project)->
        expect(project.streamsCount).to.equal(2)
        done()
