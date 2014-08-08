processNewStreamRecordings = Cine.server_lib('stream_recordings/process_new_stream_recordings.coffee')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')
EdgecastRecordings = Cine.server_model('edgecast_recordings')

describe 'processNewStreamRecordings', ->
  beforeEach ->
    @fakeFtpClient = new FakeFtpClient

    @listStub = sinon.stub()

    thingLister = (args, callback)=>
      callback null, @listStub(args)

    @fakeFtpClient.stub('list', thingLister)
    @lists = Cine.require('test/fixtures/edgecast_stream_recordings')
    @listStub.withArgs('/cines').returns(@lists)

  afterEach ->
    @fakeFtpClient.restore()

  describe 'without a matching stream', ->
    it 'errors when a stream is not found', (done)->
      processNewStreamRecordings (err)->
        expect(err).to.equal('stream not found')
        done()

  describe 'without a project', ->
    beforeEach (done)->
      p = new Project
      @stream = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines', _project: p._id, record: true)
      @stream.save done

    it 'errors when a project is not found', (done)->
      processNewStreamRecordings (err)->
        expect(err).to.equal('project not found')
        done()

  describe 'when a stream is not bound to a project', ->
    beforeEach (done)->
      @stream = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines', record: true)
      @stream.save done
    it 'errors when a stream is not bound to a project', (done)->
      processNewStreamRecordings (err)->
        expect(err).to.equal('stream not assigned to project')
        done()

  describe 'success moving recordings', ->
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

    beforeEach ->
      fullAbcList =   [{name: 'xkMOUbRPZl.mp4'}, {name: 'xkMOUbRPZl.1.mp4'},{name: 'xkMOUbRPZl.2.mp4'}]
      fullDefList =   [{name: 'ykMOUbRPZl.mp4'}, {name: 'ykMOUbRPZl.1.mp4'},{name: 'ykMOUbRPZl.2.mp4'}]

      @listStub.withArgs('/cines/abc')
        .onFirstCall().returns(fullAbcList.slice(0,0))
        .onSecondCall().returns(fullAbcList.slice(0,1))
        .onThirdCall().returns(fullAbcList.slice(0,2))

      @listStub.withArgs('/cines/def')
        .onFirstCall().returns(fullDefList.slice(0,0))
        .onSecondCall().returns(fullDefList.slice(0,1))
        .onThirdCall().returns(fullDefList.slice(0,2))

    beforeEach (done)->
      @project1 = new Project(publicKey: 'abc')
      @project1.save done

    beforeEach (done)->
      @stream1 = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines', _project: @project1._id, record: true)
      @stream1.save done

    beforeEach (done)->
      @project2 = new Project(publicKey: 'def')
      @project2.save done

    beforeEach (done)->
      @stream2 = new EdgecastStream(streamName: 'ykMOUbRPZl', instanceName: 'cines', _project: @project2._id, record: true)
      @stream2.save done

    it 'moves all the streams from a the /cines directory to the project folder', (done)->
      processNewStreamRecordings (err)=>
        expect(err).to.be.undefined
        expect(@mkdirStub.callCount).to.equal(6)
        expect(@renameStub.callCount).to.equal(6)
        done()

    assertRecordigns = (recordings)->
      expect(recordings[0].name).to.equal('xkMOUbRPZl.mp4')
      expect(recordings[0].size).to.equal(4684422)
      expect(recordings[0].date).to.be.instanceOf(Date)
      expect(recordings[0].date.toString()).to.equal('Wed Jul 16 2014 20:34:00 GMT+0000 (UTC)')

      expect(recordings[1].name).to.equal('xkMOUbRPZl.1.mp4')
      expect(recordings[1].size).to.equal(7782264)
      expect(recordings[1].date).to.be.instanceOf(Date)
      expect(recordings[1].date.toString()).to.equal('Wed Jul 16 2014 21:36:00 GMT+0000 (UTC)')

      expect(recordings[2].name).to.equal('xkMOUbRPZl.2.mp4')
      expect(recordings[2].size).to.equal(110410741)
      expect(recordings[2].date).to.be.instanceOf(Date)
      expect(recordings[2].date.toString()).to.equal('Wed Jul 16 2014 22:20:00 GMT+0000 (UTC)')

    it 'creates an EdgecastRecordings entry sorted by date', (done)->
      processNewStreamRecordings (err)=>
        expect(err).to.be.undefined
        EdgecastRecordings.find _edgecastStream: @stream1._id, (err, allRecordingsForStream)->
          expect(err).to.be.null
          expect(allRecordingsForStream).to.have.length(1)
          edgecastRecordings = allRecordingsForStream[0]
          expect(edgecastRecordings.recordings).to.have.length(3)
          assertRecordigns(edgecastRecordings.recordings)
          done()

  describe 'success removing recordings', ->
    beforeEach ->
      @deleteStub = @fakeFtpClient.stub('delete')
      @deleteStub.withArgs('/cines/xkMOUbRPZl.1.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/cines/xkMOUbRPZl.2.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/cines/xkMOUbRPZl.mp4').callsArgWith 1, null

      @deleteStub.withArgs('/cines/ykMOUbRPZl.1.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/cines/ykMOUbRPZl.2.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/cines/ykMOUbRPZl.mp4').callsArgWith 1, null

    beforeEach (done)->
      @project1 = new Project(publicKey: 'abc')
      @project1.save done

    beforeEach (done)->
      @stream1 = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines', _project: @project1._id, record: false)
      @stream1.save done

    beforeEach (done)->
      @project2 = new Project(publicKey: 'def')
      @project2.save done

    beforeEach (done)->
      @stream2 = new EdgecastStream(streamName: 'ykMOUbRPZl', instanceName: 'cines', _project: @project2._id, record: false)
      @stream2.save done

    it 'removes the recordings when record is set to false', (done)->
      processNewStreamRecordings (err)=>
        expect(err).to.be.undefined
        expect(@deleteStub.callCount).to.equal(6)
        done()
