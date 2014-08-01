_ = require('underscore')
Index = testApi Cine.api('stream_recordings/index')
Project = Cine.server_model('project')
User = Cine.server_model('user')
EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastRecordings = Cine.server_model('edgecast_recordings')

describe 'StreamArchives#Index', ->

  testApi.requresApiKey Index, 'either'

  now = new Date

  beforeEach (done)->
    @project = new Project(name: 'my project', publicKey: 'mah-pub-key')
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

  describe 'without recordings', ->
    it 'will return an empty array', (done)->
      params = publicKey: @project.publicKey, id: @projectStream._id
      Index params, (err, response, options)->
        expect(err).to.be.null
        expect(options).to.be.undefined
        expect(response).to.deep.equal([])
        done()

  describe 'with recordings', ->
    beforeEach (done)->
      @recordings = new EdgecastRecordings(_edgecastStream: @projectStream._id)
      @recordings.recordings.push name: "rec1.mp4", size: 12345, date: new Date
      @recordings.recordings.push name: "rec2.mp4", size: 67890, date: new Date
      @recordings.recordings.push name: "rec3.mp4", size: 98765, date: new Date
      @recordings.save done

    it 'will return a json of the stream archives sorted by date', (done)->
      params = publicKey: @project.publicKey, id: @projectStream._id
      Index params, (err, response, options)->
        expect(err).to.be.null
        expect(options).to.be.undefined
        expect(response).to.have.length(3)
        expect(response[0].name).to.equal('rec1.mp4')
        expect(response[0].url).to.equal('http://vod.cine.io/cines/mah-pub-key/rec1.mp4')
        done()
