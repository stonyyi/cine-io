_ = require('underscore')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')
Delete = testApi Cine.api('stream_recordings/delete')
Project = Cine.server_model('project')
User = Cine.server_model('user')
EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastRecordings = Cine.server_model('edgecast_recordings')

describe 'StreamArchives#Delete', ->

  testApi.requresApiKey Delete, 'secret'

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
      Delete params, (err, response, options)->
        expect(err).to.equal('id required')
        expect(response).to.be.null
        expect(options.status).to.equal(400)
        done()

    it 'will not return a stream not owned by a different project', (done)->
      params = secretKey: @project.secretKey, id: @notProjectStream._id
      Delete params, (err, response, options)->
        expect(err).to.equal('stream not found')
        expect(response).to.be.null
        expect(options.status).to.equal(404)
        done()

    it 'requires a name to delete', (done)->
      params = secretKey: @project.secretKey, id: @projectStream._id
      Delete params, (err, response, options)->
        expect(err).to.equal('name required')
        expect(response).to.be.null
        expect(options.status).to.equal(404)
        done()

  describe 'success', ->
    beforeEach (done)->
      @recordings = new EdgecastRecordings(_edgecastStream: @projectStream._id)
      @recordings.recordings.push name: "rec1.mp4", size: 12345, date: new Date
      @recordings.recordings.push name: "abc", size: 67890, date: new Date
      @recordings.recordings.push name: "rec3.mp4", size: 98765, date: new Date
      @recordings.save done

    beforeEach ->
      @fakeFtpClient = new FakeFtpClient
      @deleteStub = @fakeFtpClient.stub('delete')
      @deleteStub.callsArgWith 1, null

    afterEach ->
      @fakeFtpClient.restore()

    it 'will return a json of the stream archives sorted by date', (done)->
      params = secretKey: @project.secretKey, id: @projectStream._id, name: "abc"
      Delete params, (err, response, options)=>
        expect(@deleteStub.calledOnce).to.be.true
        expect(@deleteStub.args[0][0]).to.equal('/cines/abc')
        expect(err).to.be.null
        expect(options).to.be.undefined
        expect(_.keys(response)).to.deep.equal(['deletedAt'])
        expect(response.deletedAt).to.be.instanceOf(Date)
        done()

    it 'deletes the stream recording entry', (done)->
      params = secretKey: @project.secretKey, id: @projectStream._id, name: "abc"
      Delete params, (err, response, options)=>
        EdgecastRecordings.findById @recordings._id, (err, recordings)->
          expect(recordings.recordings).to.have.length(2)
          expect(_.pluck(recordings.recordings, 'name').sort()).to.deep.equal(['rec1.mp4', 'rec3.mp4'])
          done()
