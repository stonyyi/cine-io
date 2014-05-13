Project = Cine.model('project')
EdgecastStream = Cine.model('edgecast_stream')
Index = testApi Cine.api('streams/index')

describe 'EdgecastStreams#Index', ->
  testApi.requresApiKey Index

  beforeEach (done)->
    @project = new Project(name: 'my project')
    @project.save done

  beforeEach (done)->
    @olderStream = new EdgecastStream(instanceName: 'abcd', _project: @project._id)
    @olderStream.save done

  beforeEach (done)->
    d = new Date
    d.setHours(d.getHours() - 1)
    @newerStream = new EdgecastStream(instanceName: 'efgh', _project: @project._id, createdAt: d)
    @newerStream.save done

  beforeEach (done)->
    @deletedStream = new EdgecastStream(instanceName: 'efgh', _project: @project._id, deletedAt: new Date)
    @deletedStream.save done

  beforeEach (done)->
    @noOrgStream = new EdgecastStream(instanceName: 'ijkl')
    @noOrgStream.save done

  beforeEach (done)->
    @otherOrgStream = new EdgecastStream(instanceName: 'ijkl', _project: (new Project)._id)
    @otherOrgStream.save done

  it 'returns the edgecast streams for the account sorted by newest first', (done)->
    params = apiKey: @project.apiKey
    Index params, (err, response, options)=>
      expect(err).to.be.null
      expect(response).to.have.length(2)
      expect(response[0].id).to.equal(@olderStream._id.toString())
      expect(response[1].id).to.equal(@newerStream._id.toString())
      done()
