async = require('async')
fs = require('fs')
shortId = require('shortid')
Base = Cine.app('base')
HlsSender = Cine.app('hls_sender')
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

    it 'fails when there are no ts files in the m3u8', (done)->
      HlsSender 'rename', 'no_ts_files.m3u8', (err)->
        expect(err).to.equal('no ts files found')
        done()

  describe 'deleting m3u8 files', ->

    beforeEach ->
      @redisSpy = sinon.spy(client, 'del')

    afterEach ->
      @redisSpy.restore()

    it 'removes the key from redis', (done)->
      HlsSender 'rename', 'some_stream.m3u8', (err)=>
        expect(err).to.be.null
        expect(@redisSpy.calledOnce).to.be.true
        args = @redisSpy.firstCall.args
        expect(args).to.have.length(2)
        expect(args[0]).to.equal('hls:some_stream.m3u8')
        expect(args[1]).to.be.a('function')
        done()

  describe 'success', ->

    describe 'without cloudfront', ->

      beforeEach (done)->
        HlsSender 'rename', 'fake_hls.m3u8', done

      it 'writes the local url m3u8 file to redis', (done)->
        client.get "hls:some_stream.m3u8", (err, m3u8contents)->
          expect(err).to.be.null
          expected = "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-MEDIA-SEQUENCE:9\n#EXT-X-TARGETDURATION:5\n#EXTINF:5.013,\nhttp://TEST-HOST.cine.io/hls/some_stream-0987654321098.ts\n#EXTINF:5.013,\nhttp://TEST-HOST.cine.io/hls/some_stream-1234567890123.ts\n"
          expect(m3u8contents).to.equal(expected)
          done()

    describe 'with cloudfront', ->

      beforeEach (done)->
        fixture = requireFixture('nock/cloudfront/create_cloudfront_distribution')
        @cloudfrontNock = fixture(callerReference: 'short-id-generated', origin: "TEST-HOST.cine.io", logging: {bucket: 'cine-cloudfront-logging.s3.amazonaws.com', prefix: 'TEST-HOST'})
        @cloudfrontNock2 = requireFixture('nock/cloudfront/get_cloudfront_distribution')(id: 'EQGIDG4E7DZCZ')
        @oldCloudfront = HlsSender._cloudFrontURL
        HlsSender._setupCloudfrontForHls(done)

      afterEach ->
        HlsSender._cloudFrontURL = @oldCloudfront

      beforeEach (done)->
        HlsSender 'rename', 'fake_hls.m3u8', done

      it 'writes the local url m3u8 file to redis', (done)->
        client.get "hls:some_stream.m3u8", (err, m3u8contents)->
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
