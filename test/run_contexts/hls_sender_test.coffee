async = require('async')
Base = Cine.run_context('base')
HlsSender = Cine.run_context('hls_sender')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
client = Cine.server_lib('redis_client')
fs = require('fs')

describe 'hls_sender', ->

  beforeEach ->
    @oldDirectory = HlsSender._hlsDirectory
    HlsSender._hlsDirectory = Cine.path("test/fixtures")

  afterEach ->
    HlsSender._hlsDirectory = @oldDirectory

  describe 'failure', ->
    it 'fails when it cannot find the file', (done)->
      HlsSender 'rename', 'no-file.m3u8', (err)->
        expect(err.code).to.equal('ENOENT')
        done()

    it 'fails when there are no ts files in the m3u8', (done)->
      HlsSender 'rename', 'no_ts_files.m3u8', (err)->
        expect(err).to.equal('no ts files found')
        done()

    it 'fails when there is no associated stream', (done)->
      HlsSender 'rename', 'fake_hls.m3u8', (err)->
        expect(err).to.equal('stream not found')
        done()

  describe 'success', ->
    beforeEach (done)->
      @project = new Project(publicKey: 'my-pub-key')
      @project.save done

    beforeEach (done)->
      @stream = new EdgecastStream(streamName: 'some_stream', streamKey: 'some-key', _project: @project._id)
      @stream.save done


    describe 'single call', ->
      beforeEach ->
        @s3Nock = requireFixture('nock/upload_file_to_s3_success')("my-pub-key/some_stream-1234567890123.ts", "this is a fake ts file\n")
      beforeEach (done)->
        HlsSender 'rename', 'fake_hls.m3u8', done

      it 'uploads the hls_file to s3', ->
        expect(@s3Nock.isDone()).to.be.true

      it 'writes the cloudfront url m3u8 file to redis', (done)->
        client.get "hls:my-pub-key/some_stream.m3u8", (err, m3u8contents)->
          expect(err).to.be.null
          expected = "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-MEDIA-SEQUENCE:9\n#EXT-X-TARGETDURATION:5\n#EXTINF:5.013,\nhttps://cine-io-hls.s3.amazonaws.com/my-pub-key/some_stream-0987654321098.ts\n#EXTINF:5.013,\nhttps://cine-io-hls.s3.amazonaws.com/my-pub-key/some_stream-1234567890123.ts\n"
          expect(m3u8contents).to.equal(expected)
          done()

    describe 'queueing', ->
      beforeEach ->
        @s3Nock = requireFixture('nock/upload_file_to_s3_success')("my-pub-key/some_stream-1234567890123.ts", "this is a fake ts file\n")

      beforeEach ->
        @s3Nock2 = requireFixture('nock/upload_file_to_s3_success')("my-pub-key/some_stream-0987654321098.ts", "this is a second fake ts file\n", delay: true)

      beforeEach ->
        originalReadFileSync = fs.readFile
        @fsStub = sinon.stub fs, 'readFile', (name, cb)=>
          if name == Cine.path("test/fixtures/fake_hls.m3u8")
            name = Cine.path("test/fixtures/fake_hls_1.m3u8")
            @fsStub.restore()
          originalReadFileSync.call(fs, name, cb)

      it 'goes one at a time', (done)->
        hls_1_sent = false
        hls_sent = false
        HlsSender 'rename', 'fake_hls.m3u8', (err)->
          expect(err).to.be.undefined
          expect(hls_sent).to.be.false
          hls_1_sent = true
        HlsSender 'rename', 'fake_hls.m3u8', (err)->
          expect(err).to.be.undefined
          expect(hls_1_sent).to.be.true
          hls_sent = true
        testFunction = -> hls_1_sent && hls_sent
        checkFunction = (callback)->
          setTimeout(callback, 100)
        async.until testFunction, checkFunction, done
