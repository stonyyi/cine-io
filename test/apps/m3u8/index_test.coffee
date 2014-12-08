app = Cine.require('apps/m3u8')
supertest = require('supertest')
redisKeyForM3U8 = Cine.server_lib('hls/redis_key_for_m3u8')
client = Cine.server_lib('redis_client')

describe 'm3u8', ->
  beforeEach ->
    @agent = supertest.agent(app)

  beforeEach (done)->
    client.set redisKeyForM3U8.withAttribute('stream-name'), "my m3u8 file", done

  it 'serves handles the root', (done)->
    @agent.get('/').expect(200).end(done)

  it 'serves 404 for unknown routes', (done)->
    @agent
    .get('/fakeStreamId')
    .expect('Content-Type', /html/)
    .expect(404)
    .end(done)

  it 'serves 404 for not found m3u8 files', (done)->
    @agent
    .get('/fakeStreamId.m3u8')
    .expect(404)
    .end(done)

  it 'serves an m3u8 file', (done)->
    @agent
    .get('/stream-name.m3u8')
    .expect('Content-Type', "application/x-mpegurl; charset=utf-8")
    .expect(200)
    .end (err, res)->
      expect(err).to.be.null
      expect(res.text).to.equal('my m3u8 file')
      done()

  it 'serves an m3u8 file in the old format', (done)->
    @agent
    .get('/old-format/stream-name.m3u8')
    .expect('Content-Type', "application/x-mpegurl; charset=utf-8")
    .expect(200)
    .end (err, res)->
      expect(err).to.be.null
      expect(res.text).to.equal('my m3u8 file')
      done()

  it 'should render the crossdomain.xml', (done)->
    @agent
    .get('/crossdomain.xml')
    .expect('Content-Type', /text\/x-cross-domain-policy/)
    .expect(200, /<cross-domain-policy>/, done)
