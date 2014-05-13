Project = Cine.model('project')
EdgecastStream = Cine.model('edgecast_stream')
Show = testApi Cine.api('streams/show')
_ = require('underscore')

describe 'EdgecastStreams#Show', ->
  testApi.requresApiKey Show

  beforeEach (done)->
    @project = new Project(name: 'my project')
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

  it 'will return a stream owned by the project', (done)->
    params = apiKey: @project.apiKey, id: @projectStream._id
    Show params, (err, response, options)=>
      expect(err).to.be.null
      expect(response._id.toString()).to.equal(@projectStream._id.toString())
      expect(response.instanceName).to.equal('cines')
      done()

  describe 'fmleProfile', ->
    it 'will return the fmleProfile for a stream', (done)->
      params = apiKey: @project.apiKey, id: @projectStream._id, fmleProfile: true
      Show params, (err, response, options)->
        expect(err).to.be.null
        expect(_.keys(response)).to.deep.equal(['content'])
        expect(response.content).to.contain('<stream>cine1?bass35&amp;adbe-live-event=cine1ENAME</stream>')
        expect(response.content).to.contain('<url>rtmp://fso.lax.C45E.edgecastcdn.net/20C45E/cines</url>')
        done()
