makeFtpDirectory = Cine.server_lib("stream_recordings/make_ftp_directory")
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')

describe 'makeFtpDirectory', ->

  beforeEach ->
    @fakeFtpClient = new FakeFtpClient

  afterEach ->
    @fakeFtpClient.restore()

  beforeEach ->
    @mkdirStub = @fakeFtpClient.stub('mkdir')
    directoryAlreadyExists = new Error("Can't create directory: File exists")
    otherError = new Error("some other error")
    directoryAlreadyExists.code = 550
    @mkdirStub.withArgs('/does-not-exist').callsArg(1)
    @mkdirStub.withArgs('/exists').callsArgWith(1, directoryAlreadyExists)
    @mkdirStub.withArgs('/mkdir-error').callsArgWith(1, otherError)

  it 'can create a directory', (done)->
    makeFtpDirectory @fakeFtpClient, '/does-not-exist', (err)=>
      expect(err).to.be.undefined
      expect(@mkdirStub.calledOnce).to.be.true
      done()

  it 'can handle an existing directory', (done)->
    makeFtpDirectory @fakeFtpClient, '/exists', (err)=>
      expect(err).to.be.undefined
      expect(@mkdirStub.calledOnce).to.be.true
      done()

  it 'can return an error', (done)->
    makeFtpDirectory @fakeFtpClient, '/mkdir-error', (err)=>
      expect(err.message).to.equal("some other error")
      expect(@mkdirStub.calledOnce).to.be.true
      done()
