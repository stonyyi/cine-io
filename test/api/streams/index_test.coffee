Organization = Cine.model('organization')
EdgecastStream = Cine.model('edgecast_stream')
Index = testApi Cine.api('streams/index')

describe 'EdgecastStreams#Index', ->
  testApi.requresApiKey Index

  beforeEach (done)->
    @org = new Organization(name: 'my org')
    @org.save done

  beforeEach (done)->
    @olderStream = new EdgecastStream(instanceName: 'abcd', _organization: @org._id)
    @olderStream.save done

  beforeEach (done)->
    d = new Date
    d.setHours(d.getHours() - 1)
    @newerStream = new EdgecastStream(instanceName: 'efgh', _organization: @org._id, createdAt: d)
    @newerStream.save done

  beforeEach (done)->
    @deletedStream = new EdgecastStream(instanceName: 'efgh', _organization: @org._id, deletedAt: new Date)
    @deletedStream.save done

  beforeEach (done)->
    @noOrgStream = new EdgecastStream(instanceName: 'ijkl')
    @noOrgStream.save done

  beforeEach (done)->
    @otherOrgStream = new EdgecastStream(instanceName: 'ijkl', _organization: (new Organization)._id)
    @otherOrgStream.save done

  it 'returns the edgecast streams for the account sorted by newest first', (done)->
    params = apiKey: @org.apiKey
    Index params, (err, response, options)=>
      expect(err).to.be.null
      expect(response).to.have.length(2)
      expect(response[0]._id.toString()).to.equal(@olderStream._id.toString())
      expect(response[1]._id.toString()).to.equal(@newerStream._id.toString())
      done()
