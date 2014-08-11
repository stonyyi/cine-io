processFixedRecordings = Cine.server_lib('stream_recordings/process_fixed_recordings')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')
EdgecastRecordings = Cine.server_model('edgecast_recordings')

describe 'processFixedRecordings', ->
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
    @listStub.withArgs('/fixed_recordings').returns(@lists)

  afterEach ->
    @fakeFtpClient.restore()

  describe 'without a matching stream', ->
    it 'errors when a stream is not found', (done)->
      processFixedRecordings (err)->
        expect(err).to.equal('stream not found')
        done()

  describe 'without a project', ->
    beforeEach (done)->
      p = new Project
      @stream = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines', _project: p._id, record: true)
      @stream.save done

    it 'errors when a project is not found', (done)->
      processFixedRecordings (err)->
        expect(err).to.equal('project not found')
        done()

  describe 'when a stream is not bound to a project', ->
    beforeEach (done)->
      @stream = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines', record: true)
      @stream.save done
    it 'errors when a stream is not bound to a project', (done)->
      processFixedRecordings (err)->
        expect(err).to.equal('stream not assigned to project')
        done()

  describe 'success moving recordings', ->
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

    describe "moving a new recording to a folder with previous recordings", ->
      beforeEach ->
        @renameStub = @fakeFtpClient.stub('rename')
        @renameStub.withArgs('/fixed_recordings/xkMOUbRPZl.1.mp4', '/cines/abc/xkMOUbRPZl.4.mp4').callsArgWith 2, null
        @renameStub.withArgs('/fixed_recordings/xkMOUbRPZl.2.mp4', '/cines/abc/xkMOUbRPZl.5.mp4').callsArgWith 2, null
        @renameStub.withArgs('/fixed_recordings/xkMOUbRPZl.mp4', '/cines/abc/xkMOUbRPZl.3.mp4').callsArgWith 2, null

        @renameStub.withArgs('/fixed_recordings/ykMOUbRPZl.1.mp4', '/cines/def/ykMOUbRPZl.4.mp4').callsArgWith 2, null
        @renameStub.withArgs('/fixed_recordings/ykMOUbRPZl.2.mp4', '/cines/def/ykMOUbRPZl.5.mp4').callsArgWith 2, null
        @renameStub.withArgs('/fixed_recordings/ykMOUbRPZl.mp4', '/cines/def/ykMOUbRPZl.3.mp4').callsArgWith 2, null

      beforeEach ->
        fullAbcList =   [
          {name: 'xkMOUbRPZl.mp4'}
          {name: 'xkMOUbRPZl.1.mp4'}
          {name: 'xkMOUbRPZl.2.mp4'}
          {name: 'xkMOUbRPZl.3.mp4'}
          {name: 'xkMOUbRPZl.4.mp4'}
          {name: 'xkMOUbRPZl.5.mp4'}
        ]
        fullDefList =   [
          {name: 'ykMOUbRPZl.mp4'}
          {name: 'ykMOUbRPZl.1.mp4'}
          {name: 'ykMOUbRPZl.2.mp4'}
          {name: 'ykMOUbRPZl.3.mp4'}
          {name: 'ykMOUbRPZl.4.mp4'}
          {name: 'ykMOUbRPZl.5.mp4'}
        ]

        @listStub.withArgs('/cines/abc')
          .onFirstCall().returns(fullAbcList.slice(0,0+3))
          .onSecondCall().returns(fullAbcList.slice(0,1+3))
          .onThirdCall().returns(fullAbcList.slice(0,2+3))

        @listStub.withArgs('/cines/def')
          .onFirstCall().returns(fullDefList.slice(0,0+3))
          .onSecondCall().returns(fullDefList.slice(0,1+3))
          .onThirdCall().returns(fullDefList.slice(0,2+3))

      it 'moves all the streams from a the /fixed_recordings directory to the project folder', (done)->
        processFixedRecordings (err)=>
          expect(err).to.be.undefined
          expect(@mkdirStub.callCount).to.equal(6)
          expect(@renameStub.callCount).to.equal(6)
          done()

      assertRecordigns = (recordings)->
        expect(recordings[0].name).to.equal('xkMOUbRPZl.3.mp4')
        expect(recordings[0].size).to.equal(4684422)
        expect(recordings[0].date).to.be.instanceOf(Date)
        expect(recordings[0].date.toString()).to.equal('Wed Jul 16 2014 20:34:00 GMT+0000 (UTC)')

        expect(recordings[1].name).to.equal('xkMOUbRPZl.4.mp4')
        expect(recordings[1].size).to.equal(7782264)
        expect(recordings[1].date).to.be.instanceOf(Date)
        expect(recordings[1].date.toString()).to.equal('Wed Jul 16 2014 21:36:00 GMT+0000 (UTC)')

        expect(recordings[2].name).to.equal('xkMOUbRPZl.5.mp4')
        expect(recordings[2].size).to.equal(110410741)
        expect(recordings[2].date).to.be.instanceOf(Date)
        expect(recordings[2].date.toString()).to.equal('Wed Jul 16 2014 22:20:00 GMT+0000 (UTC)')

      it 'creates an EdgecastRecordings entry sorted by date', (done)->
        processFixedRecordings (err)=>
          expect(err).to.be.undefined
          EdgecastRecordings.find _edgecastStream: @stream1._id, (err, allRecordingsForStream)->
            expect(err).to.be.null
            expect(allRecordingsForStream).to.have.length(1)
            edgecastRecordings = allRecordingsForStream[0]
            expect(edgecastRecordings.recordings).to.have.length(3)
            assertRecordigns(edgecastRecordings.recordings)
            done()

    describe "with no previous recordings", ->
      beforeEach ->
        @renameStub = @fakeFtpClient.stub('rename')
        @renameStub.withArgs('/fixed_recordings/xkMOUbRPZl.1.mp4', '/cines/abc/xkMOUbRPZl.1.mp4').callsArgWith 2, null
        @renameStub.withArgs('/fixed_recordings/xkMOUbRPZl.2.mp4', '/cines/abc/xkMOUbRPZl.2.mp4').callsArgWith 2, null
        @renameStub.withArgs('/fixed_recordings/xkMOUbRPZl.mp4', '/cines/abc/xkMOUbRPZl.mp4').callsArgWith 2, null

        @renameStub.withArgs('/fixed_recordings/ykMOUbRPZl.1.mp4', '/cines/def/ykMOUbRPZl.1.mp4').callsArgWith 2, null
        @renameStub.withArgs('/fixed_recordings/ykMOUbRPZl.2.mp4', '/cines/def/ykMOUbRPZl.2.mp4').callsArgWith 2, null
        @renameStub.withArgs('/fixed_recordings/ykMOUbRPZl.mp4', '/cines/def/ykMOUbRPZl.mp4').callsArgWith 2, null

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

      it 'moves all the streams from a the /cines directory to the project folder', (done)->
        processFixedRecordings (err)=>
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
        processFixedRecordings (err)=>
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
      @deleteStub.withArgs('/fixed_recordings/xkMOUbRPZl.1.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/fixed_recordings/xkMOUbRPZl.2.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/fixed_recordings/xkMOUbRPZl.mp4').callsArgWith 1, null

      @deleteStub.withArgs('/fixed_recordings/ykMOUbRPZl.1.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/fixed_recordings/ykMOUbRPZl.2.mp4').callsArgWith 1, null
      @deleteStub.withArgs('/fixed_recordings/ykMOUbRPZl.mp4').callsArgWith 1, null

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
      processFixedRecordings (err)=>
        expect(err).to.be.undefined
        expect(@deleteStub.callCount).to.equal(6)
        done()
