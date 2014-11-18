Base = Cine.run_context('base')
HlsSender = Cine.run_context('hls_sender')

EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
client = Cine.server_lib('redis_client')

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

    beforeEach ->
      @s3Nock = requireFixture('nock/upload_file_to_s3_success')("my-pub-key/some_stream-1234567890123.ts", "this is a fake ts file\n")

    beforeEach (done)->
      HlsSender 'rename', 'fake_hls.m3u8', done
    it 'uploads the hls_file to s3', ->
      expect(@s3Nock.isDone()).to.be.true

    it 'writes the cloudfront url m3u8 file to redis', (done)->
      client.get "hls:my-pub-key/some_stream.m3u8", (err, m3u8contents)->
        expect(err).to.be.null
        expected = """
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-MEDIA-SEQUENCE:9
#EXT-X-TARGETDURATION:5
#EXTINF:5.013,
https://cine-io-hls.s3.amazonaws.com/my-pub-key/some_stream-0987654321098.ts
#EXTINF:5.013,
https://cine-io-hls.s3.amazonaws.com/my-pub-key/some_stream-1234567890123.ts\n
"""
        expect(m3u8contents).to.equal(expected)
        done()

