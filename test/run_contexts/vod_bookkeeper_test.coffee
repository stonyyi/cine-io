Base = Cine.run_context('base')
VodBookkeeper = Cine.run_context('vod_bookkeeper')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
StreamRecordings = Cine.server_model('stream_recordings')
copyFile = Cine.require('test/helpers/copy_file')
assertFileDeleted = Cine.require('test/helpers/assert_file_deleted')
fs = require('fs')
async = require('async')
cp = require('child_process')

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
        @s3Nock = requireFixture('nock/aws/upload_file_to_s3_success')("cines/this-pub-key/mystream.20141008T191601.mp4", "this is a fake video file\n")

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

      it "creates an entry in StreamRecordings", (done)->
        job = Base.scheduleJob Base.getQueueName('vod_bookkeeper'), file: @targetFile

        job.on 'complete', (err)=>
          expect(err).to.be.null
          StreamRecordings.find _edgecastStream: @stream._id, (err, allRecordingsForStream)=>
            expect(err).to.be.null
            expect(allRecordingsForStream).to.have.length(1)
            edgecastRecordings = allRecordingsForStream[0]
            expect(edgecastRecordings.recordings).to.have.length(1)
            recording = edgecastRecordings.recordings[0]
            expect(recording.name).to.equal("mystream.20141008T191601.mp4")
            expect(recording.size).to.equal(26)
            expect(recording.date).to.be.instanceOf(Date)
            assertFileDeleted(@targetFile, done)
