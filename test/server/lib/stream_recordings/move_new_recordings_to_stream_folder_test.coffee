moveNewRecordingsToStreamFolder = Cine.server_lib('stream_recordings/move_new_recordings_to_stream_folder.coffee')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')
EdgecastRecordings = Cine.server_model('edgecast_recordings')

describe 'moveNewRecordingsToStreamFolder', ->
  beforeEach ->
    @fakeFtpClient = new FakeFtpClient

    @listStub = @fakeFtpClient.stub('list')
    @lists = Cine.require('test/fixtures/edgecast_stream_recordings')
    @listStub.callsArgWith 1, null, @lists

  afterEach ->
    @fakeFtpClient.restore()

  describe 'without a matching stream', ->
    it 'errors when a stream is not found', (done)->
      moveNewRecordingsToStreamFolder (err)->
        expect(err).to.equal('stream not found')
        done()

  describe 'without a project', ->
    beforeEach (done)->
      p = new Project
      @stream = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines', _project: p._id)
      @stream.save done

    it 'errors when a project is not found', (done)->
      moveNewRecordingsToStreamFolder (err)->
        expect(err).to.equal('project not found')
        done()

  describe 'when a stream is not bound to a project', ->
    beforeEach (done)->
      @stream = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines')
      @stream.save done
    it 'errors when a stream is not bound to a project', (done)->
      moveNewRecordingsToStreamFolder (err)->
        expect(err).to.equal('stream not assigned to project')
        done()

  describe 'success', ->
    beforeEach ->
      @mkdirStub = @fakeFtpClient.stub('mkdir')
      directoryAlreadyExists = new Error("Can't create directory: File exists")
      directoryAlreadyExists.code = 550
      @mkdirStub.withArgs('/cines/abc')
        .onFirstCall().callsArgWith(1, null)
        .onSecondCall().callsArgWith(1, directoryAlreadyExists)
        .onThirdCall().callsArgWith(1, directoryAlreadyExists)
      @mkdirStub.withArgs('/cines/def')
        .onFirstCall().callsArgWith(1, null)
        .onSecondCall().callsArgWith(1, directoryAlreadyExists)
        .onThirdCall().callsArgWith(1, directoryAlreadyExists)

      @renameStub = @fakeFtpClient.stub('rename')
      @renameStub.withArgs('/cines/xkMOUbRPZl.1.mp4', '/cines/abc/xkMOUbRPZl.1.mp4').callsArgWith 2, null
      @renameStub.withArgs('/cines/xkMOUbRPZl.2.mp4', '/cines/abc/xkMOUbRPZl.2.mp4').callsArgWith 2, null
      @renameStub.withArgs('/cines/xkMOUbRPZl.mp4', '/cines/abc/xkMOUbRPZl.mp4').callsArgWith 2, null

      @renameStub.withArgs('/cines/ykMOUbRPZl.1.mp4', '/cines/def/ykMOUbRPZl.1.mp4').callsArgWith 2, null
      @renameStub.withArgs('/cines/ykMOUbRPZl.2.mp4', '/cines/def/ykMOUbRPZl.2.mp4').callsArgWith 2, null
      @renameStub.withArgs('/cines/ykMOUbRPZl.mp4', '/cines/def/ykMOUbRPZl.mp4').callsArgWith 2, null

    beforeEach (done)->
      @project1 = new Project(publicKey: 'abc')
      @project1.save done

    beforeEach (done)->
      @stream1 = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines', _project: @project1._id)
      @stream1.save done

    beforeEach (done)->
      @project2 = new Project(publicKey: 'def')
      @project2.save done

    beforeEach (done)->
      @stream2 = new EdgecastStream(streamName: 'ykMOUbRPZl', instanceName: 'cines', _project: @project2._id)
      @stream2.save done

    it 'moves all the streams from a the /cines directory to the project folder', (done)->
      moveNewRecordingsToStreamFolder (err)=>
        expect(err).to.be.undefined
        expect(@mkdirStub.callCount).to.equal(6)
        expect(@renameStub.callCount).to.equal(6)
        done()

    assertRecordigns = (recordings)->
      expect(recordings[0].name).to.equal('xkMOUbRPZl.1.mp4')
      expect(recordings[0].size).to.equal(7782264)
      expect(recordings[0].date).to.be.instanceOf(Date)
      expect(recordings[0].date.toString()).to.equal('Wed Jul 16 2014 21:36:00 GMT+0000 (UTC)')

      expect(recordings[1].name).to.equal('xkMOUbRPZl.2.mp4')
      expect(recordings[1].size).to.equal(110410741)
      expect(recordings[1].date).to.be.instanceOf(Date)
      expect(recordings[1].date.toString()).to.equal('Wed Jul 16 2014 22:20:00 GMT+0000 (UTC)')

      expect(recordings[2].name).to.equal('xkMOUbRPZl.mp4')
      expect(recordings[2].size).to.equal(4684422)
      expect(recordings[2].date).to.be.instanceOf(Date)
      expect(recordings[2].date.toString()).to.equal('Wed Jul 16 2014 20:34:00 GMT+0000 (UTC)')

    it 'creates an EdgecastRecordings entry', (done)->
      moveNewRecordingsToStreamFolder (err)=>
        expect(err).to.be.undefined
        EdgecastRecordings.find _edgecastStream: @stream1._id, (err, allRecordingsForStream)->
          expect(err).to.be.null
          expect(allRecordingsForStream).to.have.length(1)
          edgecastRecordings = allRecordingsForStream[0]
          expect(edgecastRecordings.recordings).to.have.length(3)
          assertRecordigns(edgecastRecordings.recordings)
          done()
