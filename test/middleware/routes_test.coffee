supertest = require('supertest')
app = SS.require('app').app

describe 'api routing', ->

  beforeEach ->
    @agent = supertest.agent(app)

  it 'routes to health', (done)->
    @agent.get('/api/1/health')
      .end (err, res)=>
        expect(err).to.be.null
        process.nextTick =>
          @agent.get('/api/1/health')
            .end (err, res)->
              expect(err).to.be.null
              done()
