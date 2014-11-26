basicModel = Cine.require 'test/helpers/basic_model'
basicModel('project', urlAttributes: ['publicKey'])
Project = Cine.model('project')
Streams = Cine.collection('streams')

describe 'Project', ->

  describe '#getStreams', ->
    beforeEach ->
      @fetchStub = sinon.stub(Streams.prototype, 'fetch')

    afterEach ->
      @fetchStub.restore()

    it 'return streams if already set', ->
      project = new Project()
      project.streams = "some streams"
      expect(project.getStreams()).to.equal('some streams')
      expect(@fetchStub.called).to.be.false

    it 'fetches streams', ->
      project = new Project({secretKey: "my secret"}, app: "some app")
      streams = project.getStreams()
      expect(streams).to.be.instanceOf(Streams)
      expect(streams.models).to.have.length(0)
      expect(streams.app).to.equal("some app")
      expect(@fetchStub.calledOnce).to.be.true
      expect(@fetchStub.firstCall.args).to.deep.equal([data: {secretKey: "my secret"}])

  describe '#updatedAt', ->
    it 'returns a date', ->
      project = new Project(updatedAt: (new Date).toISOString())
      expect(project.updatedAt()).to.be.instanceOf(Date)

    it 'returns null when unavailable', ->
      project = new Project()
      expect(project.updatedAt()).to.be.null
