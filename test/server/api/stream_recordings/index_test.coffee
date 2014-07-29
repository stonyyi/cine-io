_ = require('underscore')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')
Index = testApi Cine.api('stream_recordings/index')
Project = Cine.server_model('project')
User = Cine.server_model('user')
EdgecastStream = Cine.server_model('edgecast_stream')

describe 'StreamArchives#index', ->

  testApi.requresApiKey Index, 'either'

  now = new Date

  beforeEach (done)->
    @project = new Project(name: 'my project')
    @project.save done

  beforeEach (done)->
    @user = new User name: 'some user', email: 'my email', plan: 'free'
    @user.permissions.push objectId: @project._id, objectName: 'Project'
    @user.save done

  beforeEach (done)->
    @projectStream = new EdgecastStream
      instanceName: 'cines'
      eventName: 'xkMOUbRPZl'
      streamName: 'xkMOUbRPZl'
      streamKey: 'bass35'
      name: 'my fun name'
      _project: @project._id
      assignedAt: now
    @projectStream.save done

  beforeEach (done)->
    @notProjectStream = new EdgecastStream(instanceName: 'cines')
    @notProjectStream.save done

  describe 'failure', ->
    it 'requires an id', (done)->
      params = secretKey: @project.secretKey
      Index params, (err, response, options)->
        expect(err).to.equal('id required')
        expect(response).to.be.null
        expect(options.status).to.equal(400)
        done()

    it 'will not return a stream not owned by a different project', (done)->
      params = secretKey: @project.secretKey, id: @notProjectStream._id
      Index params, (err, response, options)->
        expect(err).to.equal('stream not found')
        expect(response).to.be.null
        expect(options.status).to.equal(404)
        done()

  describe 'success', ->
    beforeEach ->
      @fakeFtpClient = new FakeFtpClient
      @listStub = @fakeFtpClient.stub('list')
      @lists = Cine.require('test/fixtures/edgecast_stream_recordings')
      @listStub.callsArgWith 1, null, @lists

    afterEach ->
      @fakeFtpClient.restore()

    it 'will return a json of the stream archives sorted by date', (done)->
      params = publicKey: @project.publicKey, id: @projectStream._id
      Index params, (err, response, options)->
        expect(err).to.be.null
        expect(options).to.be.undefined
        expect(response).to.have.length(3)
        expect(response[0].name).to.equal('xkMOUbRPZl.mp4')
        expect(response[0].url).to.equal('http://vod.cine.io/cines/xkMOUbRPZl.mp4')
        done()
