redisKeyForM3U8 = Cine.server_lib('hls/redis_key_for_m3u8')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')

describe 'redisKeyForM3U8', ->

  describe '.withObjects', ->
    beforeEach ->
      @project = new Project(publicKey: 'my-pub')
      @stream = new EdgecastStream(streamName: 'my-name')
    it 'uses the public key and streamName', ->
      expect(redisKeyForM3U8.withObjects(@project, @stream)).to.equal("hls:my-pub/my-name.m3u8")

  describe '.withAttributes', ->
    it 'uses the two attributes', ->
      expect(redisKeyForM3U8.withAttributes("this-pub", "this-name")).to.equal("hls:this-pub/this-name.m3u8")
