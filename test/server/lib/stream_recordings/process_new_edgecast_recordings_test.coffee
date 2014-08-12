processNewEdgecastRecordings = Cine.server_lib("stream_recordings/process_new_edgecast_recordings")
EdgecastStream = Cine.server_model('edgecast_stream')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')

describe 'processNewEdgecastRecordings', ->

  beforeEach ->
    @fakeFtpClient = new FakeFtpClient

    @listStub = sinon.stub()

    # listStub allows for me to specify
    # stub().withArgs("/the/dir")
    # because the actual list call takes ("/the/dir", callback)
    # and you can't use sinon's .withArgs(string, callback)
    # because you do not have the exact callback function
    # so the withArgs call does not match
    @fakeFtpClient.stub 'list', (args, callback)=>
      callback null, @listStub(args)
    @lists = Cine.require('test/fixtures/edgecast_stream_recordings')
    @listStub.withArgs('/cines').returns(@lists)

  afterEach ->
    @fakeFtpClient.restore()

  describe "when the stream is set to record", ->

    beforeEach (done)->
      @stream1 = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines', record: true)
      @stream1.save done

    beforeEach (done)->
      @stream2 = new EdgecastStream(streamName: 'ykMOUbRPZl', instanceName: 'cines', record: true)
      @stream2.save done

    beforeEach ->
      @renameStub = @fakeFtpClient.stub('rename')
      @renameStub.withArgs('/cines/xkMOUbRPZl.1.mp4', '/ready_to_fix/xkMOUbRPZl.1.mp4').callsArgWith 2, null
      @renameStub.withArgs('/cines/xkMOUbRPZl.2.mp4', '/ready_to_fix/xkMOUbRPZl.2.mp4').callsArgWith 2, null
      @renameStub.withArgs('/cines/xkMOUbRPZl.mp4', '/ready_to_fix/xkMOUbRPZl.mp4').callsArgWith 2, null

      @renameStub.withArgs('/cines/ykMOUbRPZl.1.mp4', '/ready_to_fix/ykMOUbRPZl.1.mp4').callsArgWith 2, null
      @renameStub.withArgs('/cines/ykMOUbRPZl.2.mp4', '/ready_to_fix/ykMOUbRPZl.2.mp4').callsArgWith 2, null
      @renameStub.withArgs('/cines/ykMOUbRPZl.mp4', '/ready_to_fix/ykMOUbRPZl.mp4').callsArgWith 2, null

    beforeEach ->
      @mkdirStub = @fakeFtpClient.stub('mkdir')
      directoryAlreadyExists = new Error("Can't create directory: File exists")
      directoryAlreadyExists.code = 550
      @mkdirStub.withArgs('/ready_to_fix')
        .onCall(0).callsArgWith(1, null)
        .onCall(1).callsArgWith(1, directoryAlreadyExists)
        .onCall(2).callsArgWith(1, directoryAlreadyExists)
        .onCall(3).callsArgWith(1, directoryAlreadyExists)
        .onCall(4).callsArgWith(1, directoryAlreadyExists)
        .onCall(5).callsArgWith(1, directoryAlreadyExists)

    beforeEach ->
      fullAbcList =   [{name: 'xkMOUbRPZl.mp4'}, {name: 'xkMOUbRPZl.1.mp4'},{name: 'xkMOUbRPZl.2.mp4'}]
      fullDefList =   [{name: 'ykMOUbRPZl.mp4'}, {name: 'ykMOUbRPZl.1.mp4'},{name: 'ykMOUbRPZl.2.mp4'}]

      @listStub.withArgs('/ready_to_fix')
        .onFirstCall().returns(fullAbcList.slice(0,0))
        .onSecondCall().returns(fullAbcList.slice(0,1))
        .onThirdCall().returns(fullAbcList.slice(0,2))
        .onCall(3).returns(fullDefList.slice(0,0))
        .onCall(4).returns(fullDefList.slice(0,1))
        .onCall(5).returns(fullDefList.slice(0,2))

    it 'moves all the streams from a the /ready_to_fix directory to the project folder', (done)->
      processNewEdgecastRecordings (err)=>
        expect(err).to.be.undefined
        expect(@mkdirStub.callCount).to.equal(6)
        expect(@renameStub.callCount).to.equal(6)
        done()

  describe 'when the stream is set to delete', ->
    beforeEach ->
      @deleteStub = @fakeFtpClient.stub('delete')
      @deleteStub.withArgs('/cines/xkMOUbRPZl.1.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/cines/xkMOUbRPZl.2.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/cines/xkMOUbRPZl.mp4').callsArgWith 1, null

      @deleteStub.withArgs('/cines/ykMOUbRPZl.1.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/cines/ykMOUbRPZl.2.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/cines/ykMOUbRPZl.mp4').callsArgWith 1, null

    beforeEach (done)->
      @stream1 = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines', record: false)
      @stream1.save done

    beforeEach (done)->
      @stream2 = new EdgecastStream(streamName: 'ykMOUbRPZl', instanceName: 'cines', record: false)
      @stream2.save done

    it 'removes the recordings when record is set to false', (done)->
      processNewEdgecastRecordings (err)=>
        expect(err).to.be.undefined
        expect(@deleteStub.callCount).to.equal(6)
        done()
