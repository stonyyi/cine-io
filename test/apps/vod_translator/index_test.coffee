Base = Cine.app('base')
VodTranslator = Cine.app('vod_translator')
copyFile = Cine.require('test/helpers/copy_file')
assertFileDeleted = Cine.require('test/helpers/assert_file_deleted')
fs = require('fs')
async = require('async')
cp = require('child_process')

describe 'VodTranslator', ->

  describe 'processJobs', ->
    before ->
      Base.processJobs 'vod_translator', VodTranslator.jobProcessor
    after ->
      Base._recreateQueue()

    it "needs a file", (done)->
      job = Base.scheduleJob Base.getQueueName('vod_translator')
      job.on 'failed', (err)->
        # err is null which is annoying to not get a message
        done()

    it "needs a file that exists", (done)->
      nonExistentFile = Cine.path('test/fixtures/NOT_A_FILE')
      job = Base.scheduleJob Base.getQueueName('vod_translator'), file: nonExistentFile
      job.on 'failed', (err)->
        # err is null which is annoying to not get a message
        done()

    describe 'success', ->

      beforeEach (done)->
        existingFile = Cine.path('test/fixtures/fake_video_file.txt')
        @targetFile = Cine.path('test/fixtures/mystream.20141008T191601.flv')
        @expectedOutputFile = Cine.path('test/fixtures/mystream.20141008T191601.mp4')
        copyFile existingFile, @targetFile, done


      beforeEach ->
        @spy = sinon.stub cp, 'exec'
        @spy.callsArgWith(1, null, "stub stdout", "stub stderr")

      afterEach ->
        @spy.restore()

      assertFFmpegCommand = (expectedCommand, done)->
        checkValue = false
        testFunction = -> checkValue
        checkFunction = (callback)=>
          checkValue = @spy.calledOnce == true
          setTimeout callback
        async.until testFunction, checkFunction, (err)=>
          return done(err) if err
          expect(@spy.firstCall.args[0]).to.equal(expectedCommand)
          done(err)

      it "transcodes using ffmpeg using default properties", (done)->
        job = Base.scheduleJob Base.getQueueName('vod_translator'), file: @targetFile
        job.on 'complete', (err)=>
          # err is null which is annoying to not get a message
          expectedCommand = "ffmpeg -i #{@targetFile} -c:v copy -c:a copy -c:d copy -movflags faststart -f mp4 #{@expectedOutputFile}"
          assertFFmpegCommand.call this, expectedCommand, (err)=>
            expect(err).to.be.undefined
            assertFileDeleted(@targetFile, done)

      it "sends a message to the vod_bookkeeper", (done)->
        Base.processJobs 'vod_bookkeeper', (job, jobDone)=>
          expect(job.data.file).to.equal(@expectedOutputFile)
          done()
        job = Base.scheduleJob Base.getQueueName('vod_translator'), file: @targetFile
