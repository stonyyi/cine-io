supertest = require('supertest')
VodTranslator = Cine.run_context('vod_translator').app
copyFile = Cine.require('test/helpers/copy_file')
assertFileDeleted = Cine.require('test/helpers/assert_file_deleted')
fs = require('fs')
async = require('async')
cp = require('child_process')

describe 'VodTranslator', ->

  beforeEach ->
    @agent = supertest.agent(VodTranslator)

  describe '/', ->

    it "needs a file", (done)->
      @agent.post('/').expect(400).end (err, res)->
        expect(err).to.be.null
        expect(res.text).to.equal("usage: [POST] /, {file: '/full/path/to/file'}")
        done()

    it "needs a file that exists", (done)->
      nonExistentFile = Cine.path('test/fixtures/NOT_A_FILE')
      @agent
        .post('/')
        .send(file: nonExistentFile)
        .expect(400)
        .end (err, res)->
          expect(err).to.be.null
          expect(res.text).to.equal("Could not find file #{nonExistentFile}")
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
        @agent
          .post('/')
          .send(file: @targetFile, format: 'mp4')
          .expect(200)
          .end (err, res)=>
            expect(err).to.be.null
            expect(res.text).to.equal("OK")
            expectedCommand = "ffmpeg -i #{@targetFile} -f mp4 #{@expectedOutputFile}"
            assertFFmpegCommand.call this, expectedCommand, (err)=>
              expect(err).to.be.undefined
              assertFileDeleted(@targetFile, done)

      it "transcodes using ffmpeg using parameters", (done)->
        @agent
          .post('/')
          .send(file: @targetFile, format: 'mp4', audioCodec: 'aac', videoCodec: 'vp8', extra: '-movflags faststart')
          .expect(200)
          .end (err, res)=>
            expect(err).to.be.null
            expect(res.text).to.equal("OK")
            expectedCommand = "ffmpeg -i #{@targetFile} -c:v vp8 -c:a aac -movflags faststart -f mp4 #{@expectedOutputFile}"
            assertFFmpegCommand.call this, expectedCommand, (err)=>
              expect(err).to.be.undefined
              assertFileDeleted(@targetFile, done)
