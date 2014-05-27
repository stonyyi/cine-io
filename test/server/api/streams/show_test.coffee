Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
Show = testApi Cine.api('streams/show')
_ = require('underscore')

describe 'Streams#Show', ->
  testApi.requresApiKey Show, 'either'

  beforeEach (done)->
    @project = new Project(name: 'my project', plan: 'free')
    @project.save done

  beforeEach (done)->
    @projectStream = new EdgecastStream
      instanceName: 'cines'
      eventName: 'cine1ENAME'
      streamName: 'cine1'
      streamKey: 'bass35'
      _project: @project._id
    @projectStream.save done

  beforeEach (done)->
    @notProjectStream = new EdgecastStream(instanceName: 'cines')
    @notProjectStream.save done

  describe 'failure', ->
    it 'requires an id', (done)->
      params = apiKey: @project.apiKey
      Show params, (err, response, options)->
        expect(err).to.equal('id required')
        expect(response).to.be.null
        expect(options.status).to.equal(400)
        done()

    it 'will not return a stream not owned by a different project', (done)->
      params = apiKey: @project.apiKey, id: @notProjectStream._id
      Show params, (err, response, options)->
        expect(err).to.equal('stream not found')
        expect(response).to.be.null
        expect(options.status).to.equal(404)
        done()

  describe 'with api key only', ->
    it 'will return the play values stream owned by the project', (done)->
      params = apiKey: @project.apiKey, id: @projectStream._id
      Show params, (err, response, options)=>
        expect(err).to.be.null
        expectedPlayResponse =
          hls: "http://hls.cine.io/cines/cine1ENAME/cine1.m3u8"
          rtmp: "rtmp://fml.cine.io/20C45E/cines/cine1?adbe-live-event=cine1ENAME"
        expect(_.keys(response).sort()).to.deep.equal(['id', 'name', 'play'])
        expect(response.play).to.deep.equal(expectedPlayResponse)
        expect(response.name).to.deep.equal('cine1')
        expect(response.id).to.equal(@projectStream._id.toString())
        done()

    describe 'fmleProfile', ->
      it 'will not return the fmleProfile for a stream', (done)->
        params = apiKey: @project.apiKey, id: @projectStream._id, fmleProfile: true
        Show params, (err, response, options)->
          expect(err).to.equal('api secret required')
          expect(response).to.be.null
          expect(options.status).to.equal(401)
          done()

  describe 'with api secret', ->
    it 'will return the play and publish values stream owned by the project', (done)->
      params = id: @projectStream._id, apiSecret: @project.apiSecret
      Show params, (err, response, options)=>
        expect(err).to.be.null
        expectedPlayResponse =
          hls: "http://hls.cine.io/cines/cine1ENAME/cine1.m3u8"
          rtmp: "rtmp://fml.cine.io/20C45E/cines/cine1?adbe-live-event=cine1ENAME"
        expectedPublishResponse =
          url: "rtmp://stream.lax.cine.io/20C45E/cines"
          stream: "cine1?bass35&amp;adbe-live-event=cine1ENAME"
        expect(_.keys(response).sort()).to.deep.equal(['expiration', 'id', 'name', 'play', 'publish'])
        expect(response.name).to.deep.equal('cine1')
        expect(response.play).to.deep.equal(expectedPlayResponse)
        expect(response.publish).to.deep.equal(expectedPublishResponse)
        expect(response.id).to.equal(@projectStream._id.toString())
        done()

    describe 'fmleProfile', ->
      it 'will return the fmleProfile for a stream', (done)->
        params = id: @projectStream._id, fmleProfile: true, apiSecret: @project.apiSecret
        Show params, (err, response, options)->
          expect(err).to.be.null
          expect(_.keys(response)).to.deep.equal(['content'])
          expect(response.content).to.contain('<stream>cine1?bass35&amp;adbe-live-event=cine1ENAME</stream>')
          expect(response.content).to.contain('<url>rtmp://stream.lax.cine.io/20C45E/cines</url>')
          done()
