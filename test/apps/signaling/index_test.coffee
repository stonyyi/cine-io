app = Cine.require('apps/signaling')
supertest = require('supertest')

describe 'signaling', ->
  beforeEach ->
    @agent = supertest.agent(app)

  it 'serves handles the root', (done)->
    @agent.get('/').expect(200).end(done)
