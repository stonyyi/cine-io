supertest = require('supertest')
app = Cine.require('app').app
Project = Cine.server_model('project')

describe 'api routing', ->

  beforeEach ->
    @agent = supertest.agent(app)

  it 'routes to unauthenticated route', (done)->
    @agent.get('/api/1/-/health')
      .end (err, res)=>
        expect(err).to.be.null
        process.nextTick =>
          @agent.get('/api/1/-/health')
            .expect(200)
            .end (err, res)->
              expect(err).to.be.null
              done()

  describe 'authenticated', ->

    beforeEach (done)->
      @project = new Project(apiKey: 'abc', name: 'me')
      @project.save done

    it 'requires an api key', (done)->
      @agent.get('/api/1/-/project')
        .expect(401)
        .end (err, res)->
          done()

    it 'requires an valid api key', (done)->
      @agent.get('/api/1/-/project?apiKey=INVALID')
        .expect(401)
        .end (err, res)->
          done()

    it 'routes to an authenticated route', (done)->
      @agent.get('/api/1/-/project?apiKey=abc')
        .end (err, res)=>
          expect(err).to.be.null
          expect(res.body.id).to.equal(@project._id.toString())
          done()
