_ = require('underscore')
supertest = require('supertest')
app = Cine.require('app').app
User = Cine.server_model('user')
login = Cine.require 'test/helpers/login_helper'
routes = Cine.server("api_routes")

describe 'data adapter params', ->

  beforeEach ->
    routes.post['/params'] = (params, callback)->
      callback(null, params)

  afterEach ->
    delete routes.post['/params']

  beforeEach ->
    @agent = supertest.agent(app)

  beforeEach (done)->
    @user = new User(email: 'the email')
    @user.assignHashedPasswordAndSalt 'the pass', (err)=>
      @user.save(done)

  beforeEach (done)->
    login(@agent, @user, 'the pass', done)

  it 'should return the params', (done)->
    @agent
    .post('/api/1/-/params')
    .set('Accept', 'application/json')
    .expect('Content-Type', /json/)
    .send(a: 'b')
    .expect(200)
    .end (err, res)=>
      expect(err).to.be.null
      response = JSON.parse(res.text)
      expect(response).to.deep.equal(a: 'b', remoteIpAddress: '127.0.0.1', sessionUserId: @user._id.toString())
      done()
