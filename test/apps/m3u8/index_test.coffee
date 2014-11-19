app = Cine.require('apps/m3u8')
supertest = require('supertest')
redisKeyForM3U8 = Cine.server_lib('hls/redis_key_for_m3u8')
client = Cine.server_lib('redis_client')

describe 'm3u8', ->
  beforeEach ->
    @agent = supertest.agent(app)

  beforeEach (done)->
    client.set redisKeyForM3U8.withAttributes("pub-key", 'stream-name'), "my m3u8 file", done

  it 'serves does not handle the root', (done)->
    @agent.get('/').expect(404).end(done)

  it 'serves 404 for not found m3u8 files', (done)->
    @agent
    .get('/fakePubKey/fakeStreamId')
    .expect('Content-Type', /html/)
    .expect(404)
    .end(done)

  it 'serves an m3u8 file', (done)->
    @agent
    .get('/pub-key/stream-name.m3u8')
    .expect('Content-Type', "application/x-mpegurl; charset=utf-8")
    .expect(200)
    .end (err, res)->
      expect(err).to.be.null
      expect(res.text).to.equal('my m3u8 file')
      done()