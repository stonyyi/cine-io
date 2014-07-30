Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
StreamsShow = Cine.api('streams/show')
Show = testApi StreamsShow
_ = require('underscore')

describe 'Streams#Show', ->
  testApi.requresApiKey Show, 'either'

  now = new Date

  beforeEach (done)->
    @project = new Project(name: 'my project')
    @project.save done

  beforeEach (done)->
    @projectStream = new EdgecastStream
      instanceName: 'cines'
      eventName: 'cine1ENAME'
      streamName: 'cine1'
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
      params = publicKey: @project.publicKey
      Show params, (err, response, options)->
        expect(err).to.equal('id required')
        expect(response).to.be.null
        expect(options.status).to.equal(400)
        done()

    it 'will not return a stream not owned by a different project', (done)->
      params = publicKey: @project.publicKey, id: @notProjectStream._id
      Show params, (err, response, options)->
        expect(err).to.equal('stream not found')
        expect(response).to.be.null
        expect(options.status).to.equal(404)
        done()

  describe 'with public key only', ->
    it 'will return the play values stream owned by the project', (done)->
      params = publicKey: @project.publicKey, id: @projectStream._id
      Show params, (err, response, options)=>
        expect(err).to.be.null
        expectedPlayResponse =
          hls: "http://hls.cine.io/cines/cine1ENAME/cine1.m3u8"
          rtmp: "rtmp://fml.cine.io/20C45E/cines/cine1?adbe-live-event=cine1ENAME"
        expect(_.keys(response).sort()).to.deep.equal(['id', 'name', 'play', 'streamName'])
        expect(response.play).to.deep.equal(expectedPlayResponse)
        expect(response.streamName).to.deep.equal('cine1')
        expect(response.name).to.deep.equal('my fun name')
        expect(response.id).to.equal(@projectStream._id.toString())
        done()

    describe 'fmleProfile', ->
      it 'will not return the fmleProfile for a stream', (done)->
        params = publicKey: @project.publicKey, id: @projectStream._id, fmleProfile: true
        Show params, (err, response, options)->
          expect(err).to.equal('secret key required')
          expect(response).to.be.null
          expect(options.status).to.equal(401)
          done()

  describe 'with secret key', ->
    it 'will return the play and publish values stream owned by the project', (done)->
      params = id: @projectStream._id, secretKey: @project.secretKey
      Show params, (err, response, options)=>
        expect(err).to.be.null
        expectedPlayResponse =
          hls: "http://hls.cine.io/cines/cine1ENAME/cine1.m3u8"
          rtmp: "rtmp://fml.cine.io/20C45E/cines/cine1?adbe-live-event=cine1ENAME"
        expectedPublishResponse =
          url: "rtmp://stream.lax.cine.io/20C45E/cines"
          stream: "cine1?bass35&amp;adbe-live-event=cine1ENAME"
        expect(_.keys(response).sort()).to.deep.equal(['assignedAt', 'expiration', 'id', 'name', 'password', 'play', 'publish', 'record', 'streamName'])
        expect(response.streamName).to.deep.equal('cine1')
        expect(response.name).to.deep.equal('my fun name')
        expect(response.password).to.deep.equal('bass35')
        expect(response.play).to.deep.equal(expectedPlayResponse)
        expect(response.publish).to.deep.equal(expectedPublishResponse)
        expect(response.id).to.equal(@projectStream._id.toString())
        expect(response.assignedAt.toString()).to.equal(now.toString())
        done()

    describe 'fmleProfile', ->
      it 'will return the fmleProfile for a stream', (done)->
        params = id: @projectStream._id, fmleProfile: true, secretKey: @project.secretKey
        Show params, (err, response, options)->
          expect(err).to.be.null
          expect(_.keys(response)).to.deep.equal(['content'])
          expect(response.content).to.contain('<stream>cine1?bass35&amp;adbe-live-event=cine1ENAME</stream>')
          expect(response.content).to.contain('<url>rtmp://stream.lax.cine.io/20C45E/cines</url>')
          done()

  describe 'deleted streams', ->
    beforeEach (done)->
      @projectStream.deletedAt = new Date
      @projectStream.save done
    it 'will not return deleted streams', (done)->
      params = id: @projectStream._id, secretKey: @project.secretKey
      Show params, (err, response, options)->
        expect(err).to.equal('stream not found')
        expect(response).to.be.null
        expect(options).to.deep.equal(status: 404)
        done()

    it 'will be returned in the full json when used', (done)->
      StreamsShow.fullJSON @projectStream, (err, streamJSON)->
        expect(streamJSON.deletedAt).to.be.instanceOf(Date)
        done()

    it 'will be not returned in the play json when used', (done)->
      StreamsShow.playJSON @projectStream, (err, streamJSON)->
        expect(streamJSON.deletedAt).to.be.undefined
        done()
