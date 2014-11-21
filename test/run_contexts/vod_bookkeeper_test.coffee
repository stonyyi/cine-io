Base = Cine.run_context('base')
VodBookkeeper = Cine.run_context('vod_bookkeeper')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
EdgecastRecordings = Cine.server_model('edgecast_recordings')
copyFile = Cine.require('test/helpers/copy_file')
assertFileDeleted = Cine.require('test/helpers/assert_file_deleted')
fs = require('fs')
async = require('async')
cp = require('child_process')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')

describe 'VodBookkeeper', ->

  directoryAlreadyExists = new Error("Can't create directory: File exists")
  directoryAlreadyExists.code = 550

  describe 'processJobs', ->
    before ->
      Base.processJobs 'vod_bookkeeper', VodBookkeeper.jobProcessor
    after ->
      Base._recreateQueue()

    it "needs a file", (done)->
      job = Base.scheduleJob Base.getQueueName('vod_bookkeeper')
      job.on 'failed', (err)->
        # err is null which is annoying to not get a message
        done()

    it "needs a file that exists", (done)->
      nonExistentFile = Cine.path('test/fixtures/NOT_A_FILE')
      job = Base.scheduleJob Base.getQueueName('vod_bookkeeper'), file: nonExistentFile
      job.on 'failed', (err)->
        # err is null which is annoying to not get a message
        done()

    describe 'success', ->

      beforeEach (done)->
        @project = new Project publicKey: 'this-pub-key'
        @project.save done

      beforeEach (done)->
        @stream = new EdgecastStream streamName: 'mystream', instanceName: 'cines', record: true, _project: @project._id
        @stream.save done

      beforeEach (done)->
        existingFile = Cine.path('test/fixtures/fake_video_file.txt')
        @targetFile = Cine.path('test/fixtures/mystream.20141008T191601.mp4')
        copyFile existingFile, @targetFile, done

      beforeEach ->
        @fakeFtpClient = new FakeFtpClient

        @listStub = sinon.stub()

        # listStub allows for me to specify
        # stub().withArgs("/the/dir")
        # because the actual list call takes ("/the/dir", callback)
        # and you can't use sinon's .withArgs(string, callback)
        # because you do not have the exact callback function
        # so the withArgs call does not match
        @fakeFtpClient.stub 'list', (directory, callback)=>
          callback null, @listStub(directory)
        list = [
          {
          type: 'd',
          name: 'mynewdir',
          target: undefined,
          rights: { user: 'rwx', group: 'rx', other: 'rx' },
          owner: '65534',
          group: 'nogroup',
          size: 59,
          date: "Thu Jul 31 2014 23:08:00 GMT+0000 (UTC)"
          }, {
            type: '-',
            name: 'mystream.mp4',
            target: undefined,
            rights: { user: 'rw', group: 'rw', other: 'r' },
            owner: '65534',
            group: 'nogroup',
            size: 4684422,
            date: "Wed Jul 16 2014 20:34:00 GMT+0000 (UTC)"
          }, {
            type: '-',
            name: 'mystream.1.mp4',
            target: undefined,
            rights: { user: 'rw', group: 'rw', other: 'r' },
            owner: '65534',
            group: 'nogroup',
            size: 4684422,
            date: "Wed Jul 16 2014 20:34:00 GMT+0000 (UTC)"
          }
        ]
        @listStub.withArgs('/cines/this-pub-key').returns(list)

      afterEach ->
        @fakeFtpClient.restore()

      beforeEach ->
        @mkdirStub = @fakeFtpClient.stub('mkdir')
        @mkdirStub.withArgs('/cines/this-pub-key')
          .onFirstCall().callsArgWith(1, null)
          .onSecondCall().callsArgWith(1, directoryAlreadyExists)

      beforeEach ->
        @s3Nock = requireFixture('nock/aws/upload_file_to_s3_success')("cines/this-pub-key/mystream.20141008T191601.mp4", "this is a fake video file\n")

      beforeEach ->
        @putStub = @fakeFtpClient.stub('put').callsArg(2)

      beforeEach ->
        @endSpy = sinon.spy @fakeFtpClient, 'end'

      it  "deletes the target file", (done)->
        job = Base.scheduleJob Base.getQueueName('vod_bookkeeper'), file: @targetFile

        job.on 'complete', (err)=>
          expect(err).to.be.null
          assertFileDeleted(@targetFile, done)

      it  "uploads the file to s3", (done)->
        job = Base.scheduleJob Base.getQueueName('vod_bookkeeper'), file: @targetFile

        job.on 'complete', (err)=>
          expect(err).to.be.null
          expect(@s3Nock.isDone()).to.be.true
          done()

      it  "uploads to the project directory place", (done)->
        job = Base.scheduleJob Base.getQueueName('vod_bookkeeper'), file: @targetFile

        job.on 'complete', (err)=>
          # err is null which is annoying to not get a message
          expect(err).to.be.null
          expect(@putStub.calledOnce).to.be.true
          args = @putStub.firstCall.args
          expect(args).to.have.length(3)
          expect(args[0]).to.equal(@targetFile)
          expect(args[1]).to.equal("/cines/this-pub-key/mystream.20141008T191601.mp4")
          expect(args[2]).to.be.a("function")
          assertFileDeleted(@targetFile, done)

      it  "closes the ftp connection", (done)->
        job = Base.scheduleJob Base.getQueueName('vod_bookkeeper'), file: @targetFile

        job.on 'complete', (err)=>
          # err is null which is annoying to not get a message
          expect(err).to.be.null
          expect(@endSpy.calledOnce).to.be.true
          done()

      it "creates an entry in EdgecastRecordings", (done)->
        job = Base.scheduleJob Base.getQueueName('vod_bookkeeper'), file: @targetFile

        job.on 'complete', (err)=>
          expect(err).to.be.null
          EdgecastRecordings.find _edgecastStream: @stream._id, (err, allRecordingsForStream)=>
            expect(err).to.be.null
            expect(allRecordingsForStream).to.have.length(1)
            edgecastRecordings = allRecordingsForStream[0]
            expect(edgecastRecordings.recordings).to.have.length(1)
            recording = edgecastRecordings.recordings[0]
            expect(recording.name).to.equal("mystream.20141008T191601.mp4")
            expect(recording.size).to.equal(26)
            expect(recording.date).to.be.instanceOf(Date)
            assertFileDeleted(@targetFile, done)
