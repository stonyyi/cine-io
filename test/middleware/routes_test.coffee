supertest = require('supertest')
app = SS.require('app').app
Organization = SS.model('organization')

describe 'api routing', ->

  beforeEach ->
    @agent = supertest.agent(app)

  it 'routes to unauthenticated route', (done)->
    @agent.get('/api/1/health')
      .end (err, res)=>
        expect(err).to.be.null
        process.nextTick =>
          @agent.get('/api/1/health')
            .expect(200)
            .end (err, res)->
              expect(err).to.be.null
              done()

  describe 'authenticated', ->
    beforeEach resetMongo

    beforeEach (done)->
      @organization = new Organization(apiKey: 'abc', name: 'me')
      @organization.save done

    it 'requires an api key', (done)->
      @agent.get('/api/1/me')
        .expect(401)
        .end (err, res)=>
          done()

    it 'requires an valid api key', (done)->
      @agent.get('/api/1/me?apikey=INVALID')
        .expect(401)
        .end (err, res)=>
          done()

    it 'routes to an authenticated route', (done)->
        @agent.get('/api/1/me?apikey=abc')
          .end (err, res)=>
            expect(err).to.be.null
            expect(res.body._id).to.equal(@organization._id.toString())
            done()
