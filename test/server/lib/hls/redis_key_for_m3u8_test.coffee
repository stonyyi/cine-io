redisKeyForM3U8 = Cine.server_lib('hls/redis_key_for_m3u8')
EdgecastStream = Cine.server_model('edgecast_stream')

describe 'redisKeyForM3U8', ->

  describe '.withObject', ->
    beforeEach ->
      @stream = new EdgecastStream(streamName: 'my-name')
    it 'uses the public key and streamName', ->
      expect(redisKeyForM3U8.withObject(@stream)).to.equal("hls:my-name.m3u8")

  describe '.withAttributes', ->
    it 'uses the two attributes', ->
      expect(redisKeyForM3U8.withAttribute("this-name")).to.equal("hls:this-name.m3u8")
