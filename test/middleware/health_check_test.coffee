supertest = require('supertest')
app = Cine.require('app').app

describe 'test', ->
  beforeEach ->
    @agent = supertest.agent(app)

  it 'returns a 200', (done)->
    @agent.get('/health').expect(200).end(done)
