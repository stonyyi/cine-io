Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
Index = testApi Cine.api('streams/index')

describe 'Streams#Index', ->
  testApi.requresApiKey Index, 'secret'

  beforeEach (done)->
    @project = new Project(name: 'my project')
    @project.save done

  beforeEach (done)->
    d = new Date
    d.setHours(d.getMinutes() - 3)

    @olderStream = new EdgecastStream(instanceName: 'abcd', _project: @project._id, name: 'ddd', createdAt: d, streamName: 'ddd-3')
    @olderStream.save done

  beforeEach (done)->
    d = new Date
    d.setHours(d.getMinutes() - 2)
    @olderStream2 = new EdgecastStream(instanceName: 'abcd', _project: @project._id, name: 'ddd', createdAt: d, streamName: 'ddd-4')
    @olderStream2.save done

  beforeEach (done)->
    d = new Date
    d.setHours(d.getMinutes() - 1)
    @olderStream3 = new EdgecastStream(instanceName: 'abcd', _project: @project._id, name: 'fff', createdAt: d, streamName: 'fff-3')
    @olderStream3.save done

  beforeEach (done)->
    d = new Date
    d.setHours(d.getHours() - 1)
    @newerStream = new EdgecastStream(instanceName: 'efgh', _project: @project._id, createdAt: d, streamName: 'efgh-name')
    @newerStream.save done

  beforeEach (done)->
    @deletedStream = new EdgecastStream(instanceName: 'efgh', _project: @project._id, deletedAt: new Date, streamName: 'efgh-name2')
    @deletedStream.save done

  beforeEach (done)->
    @noOrgStream = new EdgecastStream(instanceName: 'ijkl', streamName: 'ijkl-name')
    @noOrgStream.save done

  beforeEach (done)->
    @otherOrgStream = new EdgecastStream(instanceName: 'ijkl', _project: (new Project)._id, streamName: 'random-1')
    @otherOrgStream.save done

  it 'returns the edgecast streams with publish options when given an secret key', (done)->
    params = secretKey: @project.secretKey
    Index params, (err, response, options)->
      expect(err).to.be.undefined
      expect(response).to.have.length(4)
      expect(response[0].publish).to.be.instanceOf(Object)
      expect(response[1].publish).to.be.instanceOf(Object)
      expect(response[2].publish).to.be.instanceOf(Object)
      expect(response[3].publish).to.be.instanceOf(Object)
      done()

  it 'returns the edgecast streams by name ', (done)->
    params = secretKey: @project.secretKey, name: 'ddd'
    Index params, (err, response, options)=>
      expect(err).to.be.undefined
      expect(response).to.have.length(2)
      expect(response[0].id.toString()).to.equal(@olderStream2._id.toString())
      expect(response[1].id.toString()).to.equal(@olderStream._id.toString())
      expect(response[0].publish).to.be.instanceOf(Object)
      expect(response[1].publish).to.be.instanceOf(Object)
      done()

  it 'returns the edgecast streams with a localized publish url when given an ipAddress', (done)->
    # 81.169.145.154 is berlin, germany
    params = secretKey: @project.secretKey, ipAddress: '81.169.145.154'
    Index params, (err, response, options)->
      expect(err).to.be.undefined
      expect(response).to.have.length(4)
      expect(response[0].publish.url).to.include('publish-ams1.cine.io')
      expect(response[1].publish.url).to.include('publish-ams1.cine.io')
      done()
