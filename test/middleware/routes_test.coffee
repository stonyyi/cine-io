supertest = require('supertest')
app = SS.require('app').app

describe 'api routing', ->

  beforeEach ->
    @agent = supertest.agent(app)
    console.log('before listengin')
    @agent.app.on 'listening', (here)->
      console.log('dhdhchycg')


  it 'routes to health', (done)->
    console.log('starting test')
    @agent.get('/api/1/health')
      .end (err, res)=>
        expect(err).to.be.null
        process.nextTick =>
          @agent.get('/api/1/health')
            .end (err, res)->
              console.log('222', err)
              expect(err).to.be.null
              done()
