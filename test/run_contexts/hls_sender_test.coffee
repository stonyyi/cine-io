async = require('async')
fs = require('fs')
shortId = require('shortid')
Base = Cine.run_context('base')
HlsSender = Cine.run_context('hls_sender')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
client = Cine.server_lib('redis_client')
cloudfront = Cine.server_lib("aws/cloudfront")

describe 'hls_sender', ->

  beforeEach ->
    @shortIDSpy = sinon.stub(shortId, 'generate').returns("short-id-generated")
  afterEach ->
    @shortIDSpy.restore()

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


    describe 'without cloudfront', ->

      beforeEach (done)->
        HlsSender 'rename', 'fake_hls.m3u8', done

      it 'writes the local url m3u8 file to redis', (done)->
        client.get "hls:my-pub-key/some_stream.m3u8", (err, m3u8contents)->
          expect(err).to.be.null
          expected = "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-MEDIA-SEQUENCE:9\n#EXT-X-TARGETDURATION:5\n#EXTINF:5.013,\nhttp://TEST-HOST.cine.io/hls/some_stream-0987654321098.ts\n#EXTINF:5.013,\nhttp://TEST-HOST.cine.io/hls/some_stream-1234567890123.ts\n"
          expect(m3u8contents).to.equal(expected)
          done()

    describe 'with cloudfront', ->

      beforeEach (done)->
        fixture = requireFixture('nock/cloudfront/create_cloudfront_distribution')
        @cloudfrontNock = fixture(callerReference: 'short-id-generated', origin: "TEST-HOST.cine.io")
        @cloudfrontNock2 = requireFixture('nock/cloudfront/get_cloudfront_distribution')(id: 'EQGIDG4E7DZCZ')
        @oldCloudfront = HlsSender._cloudFrontURL
        HlsSender._setupCloudfrontForHls(done)

      afterEach ->
        HlsSender._cloudFrontURL = @oldCloudfront

      beforeEach (done)->
        HlsSender 'rename', 'fake_hls.m3u8', done

      it 'writes the local url m3u8 file to redis', (done)->
        client.get "hls:my-pub-key/some_stream.m3u8", (err, m3u8contents)->
          expect(err).to.be.null
          expected = "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-MEDIA-SEQUENCE:9\n#EXT-X-TARGETDURATION:5\n#EXTINF:5.013,\nhttp://d28ayna0xo97kz.cloudfront.net/hls/some_stream-0987654321098.ts\n#EXTINF:5.013,\nhttp://d28ayna0xo97kz.cloudfront.net/hls/some_stream-1234567890123.ts\n"
          expect(m3u8contents).to.equal(expected)
          done()

    describe 'queueing', ->

      beforeEach ->
        callCount = 0
        @clientStub = sinon.stub client, 'set', (key, value, callback)->
          if callCount == 0
            callCount += 1
            setTimeout callback, 50
          else callback()

      afterEach ->
        @clientStub.restore()

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
