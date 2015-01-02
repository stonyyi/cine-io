app = Cine.require('apps/home/embed')
supertest = require('supertest')

describe 'embed', ->
  beforeEach ->
    @agent = supertest.agent(app)

  expectSuccess = (done)->
    return (err, res)->
      expect(res.text).to.include("<title>cine.io player embed</title>")
      expect(res.text).to.include('<script type="text/javascript" src="//cdn.cine.io/cineio-broadcast.js"></script>')
      done(err)

  it 'serves does not handle the root', (done)->
    @agent.get('/').expect(404).end(done)

  it 'serves the embed page with a public key and stream id', (done)->
    @agent
    .get('/fakePubKey/fakeStreamId')
    .expect('Content-Type', /html/)
    .expect(200)
    .end expectSuccess(done)
