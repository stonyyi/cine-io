Project = Cine.server_model('project')
User = Cine.server_model('user')
EdgecastStream = Cine.server_model('edgecast_stream')
Create = testApi Cine.api('streams/create')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
_ = require('underscore')

describe 'Streams#Create', ->
  testApi.requresApiKey Create, 'secret'

  beforeEach (done)->
    @project = new Project(name: 'my project')
    @project.save done

  beforeEach (done)->
    @user = new User name: 'some user', email: 'my email', plan: 'free'
    @user.permissions.push objectId: @project._id, objectName: 'Project'
    @user.save done

  it 'can error with no available edgecast stream', (done)->
    params = secretKey: @project.secretKey
    Create params, (err, response, options)->
      expect(err).to.equal('Next stream not available, please try again later')
      expect(response).to.be.null
      expect(options.status).to.equal(400)
      done()

  describe 'with available stream', (done)->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'cines', streamName: 'cine1', streamKey: 'bass35', eventName: 'cine1ENAME')
      @stream.save done

    stubEdgecast()

    it 'returns an edgecast stream', (done)->
      params = secretKey: @project.secretKey
      Create params, (err, response, options)=>
        expect(err).to.be.null
        expectedPlayResponse =
          hls: "http://hls.cine.io/cines/cine1ENAME/cine1.m3u8"
          rtmp: "rtmp://fml.cine.io/20C45E/cines/cine1?adbe-live-event=cine1ENAME"
        expectedPublishResponse =
          url: "rtmp://stream.lax.cine.io/20C45E/cines"
          stream: "cine1?bass35&amp;adbe-live-event=cine1ENAME"
        expect(_.keys(response).sort()).to.deep.equal(['assignedAt', 'expiration', 'id', 'name', 'password', 'play', 'publish', 'record', 'streamName'])
        expect(response.play).to.deep.equal(expectedPlayResponse)
        expect(response.publish).to.deep.equal(expectedPublishResponse)
        expect(response.id).to.equal(@stream._id.toString())
        expect(response.streamName).to.equal('cine1')
        expect(response.password).to.equal('bass35')
        expect(response.assignedAt).to.be.ok
        expect(response.record).to.be.false
        expect(options).to.be.undefined
        done()

    it 'assigns the stream to the project', (done)->
      params = secretKey: @project.secretKey
      Create params, (err, response, options)=>
        EdgecastStream.findById @stream._id, (err, stream)=>
          expect(err).to.be.null
          expect(stream._project.toString()).to.equal(@project._id.toString())
          done()

    it 'adds a stream name', (done)->
      params = secretKey: @project.secretKey, name: 'my fun stream'
      Create params, (err, response, options)=>
        expect(err).to.be.null
        expect(response.name).to.equal('my fun stream')
        EdgecastStream.findById @stream._id, (err, stream)=>
          expect(err).to.be.null
          expect(stream._project.toString()).to.equal(@project._id.toString())
          expect(stream.name).to.equal('my fun stream')
          done()

    it 'can pass a record parameter', (done)->
      params = secretKey: @project.secretKey, record: 'true'
      Create params, (err, response, options)=>
        expect(err).to.be.null
        expect(response.record).to.be.true
        EdgecastStream.findById @stream._id, (err, stream)=>
          expect(err).to.be.null
          expect(stream._project.toString()).to.equal(@project._id.toString())
          expect(stream.record).to.be.true
          done()
