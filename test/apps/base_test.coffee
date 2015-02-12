Base = Cine.app('base')
os = require("os")
fs = require("fs")

describe 'Base', ->

  # I know this also happens in the test suite
  # but good to make sure if the test suite changes
  # this will still return true
  it 'ensures the timezone', ->
    expect(process.env.TZ).to.equal("UTC")

  # I know this also happens in the test suite
  # but good to make sure if the test suite changes
  # this will still return true
  it 'loads the environment', ->
    expect(typeof Cine).to.equal("object")


  describe '.app', ->
    it 'returns an express instance', ->
      app = Base.app("app test")
      expect(app.get).to.be.a('function')
      expect(app.post).to.be.a('function')
      expect(app.listen).to.be.a('function')

  describe 'getQueueName', ->

    it 'includes the hostname', ->
      expect(Base.getQueueName('my-run-context')).to.equal("TEST-HOST-my-run-context-incoming")

  describe 'watch', ->
    beforeEach ->
      @watchSpy = sinon.spy fs, 'watch'
    afterEach ->
      @watchSpy.restore()

    it 'delegates to fs.watch', ->
      path = Cine.path("test/fixtures/file.txt")
      cbFunction = ->
      watcher = Base.watch(path, cbFunction)
      expect(@watchSpy.calledOnce).to.be.true
      args = @watchSpy.firstCall.args
      expect(args).to.have.length(2)
      expect(args[0]).to.equal(path)
      expect(args[1]).to.equal(cbFunction)
      watcher.close()

  describe 'listen', ->
    beforeEach ->
      @oldPort = process.env.PORT
      delete process.env.PORT
    afterEach ->
      delete process.env.PORT
      process.env.PORT = @oldPort if @oldPort

    it 'calls listen on an app with a default port', ->
      app = Base.app()
      listenStub = sinon.stub(app, 'listen')
      Base.listen(app)
      expect(listenStub.calledOnce).to.be.true
      args = listenStub.firstCall.args
      expect(args).to.deep.equal([80])

    it 'calls listen on an app with an environment port', ->
      app = Base.app()
      oldPort = process.env.PORT
      process.env.PORT = "env port"
      listenStub = sinon.stub(app, 'listen')
      Base.listen(app, "the port")
      expect(listenStub.calledOnce).to.be.true
      args = listenStub.firstCall.args
      expect(args).to.deep.equal(["env port"])

  describe 'processJobs', ->
    it 'is tested'
