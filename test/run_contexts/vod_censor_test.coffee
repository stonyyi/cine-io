supertest = require('supertest')
Base = Cine.run_context('base')
VodCensor = Cine.run_context('vod_censor').app
copyFile = Cine.require('test/helpers/copy_file')
assertFileDeleted = Cine.require('test/helpers/assert_file_deleted')
fs = require('fs')
async = require('async')
EdgecastStream = Cine.server_model('edgecast_stream')

describe 'VodCensor', ->

  beforeEach ->
    @agent = supertest.agent(VodCensor)

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
        @stream = new EdgecastStream(streamName: 'mystream', instanceName: 'cines', record: false)
        @stream.save done

      beforeEach (done)->
        existingFile = Cine.path('test/fixtures/fake_video_file.txt')
        @targetFile = Cine.path('test/fixtures/mystream.20141008T191601.flv')
        copyFile existingFile, @targetFile, done

      describe 'with a stream that is not set to record', ->

        it "deletes a file if the stream is not set to record", (done)->
          @agent
            .post('/')
            .send(file: @targetFile)
            .expect(200)
            .end (err, res)=>
              expect(err).to.be.null
              expect(res.text).to.equal("OK")
              assertFileDeleted(@targetFile, done)

      describe 'with a stream that is set to record', ->
        beforeEach (done)->
          @stream.record = true
          @stream.save done

        afterEach (done)->
          fs.unlink @targetFile, done

        afterEach ->
          Base._recreateQueue()

        it "schedules a message in the transocde service", (done)->
          Base.processJobs 'vod_translator', (job, jobDone)=>
            expect(job.data.file).to.equal(@targetFile)
            done()
          @agent
            .post('/')
            .send(file: @targetFile)
            .expect(200)
            .end (err, res)->
              expect(err).to.be.null
              expect(res.text).to.equal("OK")
