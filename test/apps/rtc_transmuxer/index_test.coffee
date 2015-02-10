app = Cine.require('apps/rtc_transmuxer').app
supertest = require('supertest')

describe 'rtc_transmuxer', ->
  beforeEach ->
    @agent = supertest.agent(app)

  it 'serves handles the root', (done)->
    @agent.get('/').expect(200).end(done)
