Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
Index = testApi Cine.api('streams/index')

describe 'Streams#Index', ->
  testApi.requresApiKey Index, 'secret'

  beforeEach (done)->
    @project = new Project(name: 'my project', plan: 'enterprise')
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

  it 'returns the edgecast streams with publish options when given an secret key', (done)->
    params = secretKey: @project.secretKey
    Index params, (err, response, options)->
      expect(err).to.be.undefined
      expect(response).to.have.length(2)
      expect(response[0].publish).to.be.instanceOf(Object)
      expect(response[1].publish).to.be.instanceOf(Object)
      done()
