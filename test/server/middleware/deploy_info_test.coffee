supertest = require('supertest')
app = Cine.require('app').app

describe 'deployinfo', ->
  beforeEach ->
    @agent = supertest.agent(app)
    @herokuResponse = requireFixture('nock/heroku_releases_response')()

  it 'returns a 200', (done)->
    @agent.get('/deployinfo').expect(200).end (err, res)=>
      expect(JSON.parse(res.text)).to.deep.equal("sha":"312a466")
      expect(@herokuResponse.isDone()).to.be.true
      done()
