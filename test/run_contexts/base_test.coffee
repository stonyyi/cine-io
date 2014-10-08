Base = Cine.run_context('base')

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
      app = Base.app()
      expect(app.get).to.be.a('function')
      expect(app.post).to.be.a('function')
      expect(app.listen).to.be.a('function')

  describe 'listen', ->
    beforeEach ->
      @oldPort = process.env.PORT
      delete process.env.PORT
    afterEach ->
      delete process.env.PORT
      process.env.PORT = @oldPort if @oldPort

    it 'calls listen on an app with a port', ->
      app = Base.app()
      listenStub = sinon.stub(app, 'listen')
      Base.listen(app, "the port")
      expect(listenStub.calledOnce).to.be.true
      args = listenStub.firstCall.args
      expect(args).to.deep.equal(["the port"])

    it 'calls listen on an app with an environment port', ->
      app = Base.app()
      oldPort = process.env.PORT
      process.env.PORT = "env port"
      listenStub = sinon.stub(app, 'listen')
      Base.listen(app, "the port")
      expect(listenStub.calledOnce).to.be.true
      args = listenStub.firstCall.args
      expect(args).to.deep.equal(["env port"])
