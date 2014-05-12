RememberMe = Cine.middleware('authentication/remember_me')
supertest = require('supertest')
RememberMeToken = Cine.model('remember_me_token')
User = Cine.model('user')
app = Cine.require('app').app

describe 'RememberMe', ->

  describe 'rememberMe authentication', ->

    app.get '/whoami', (req, res)->
      res.send(req.currentUser)

    beforeEach (done)->
      @agent = supertest.agent(app)
      loginUser @agent, (err, remember_me)=>
        @remember_me = remember_me
        process.nextTick ->
          done(err)

    beforeEach ->
      @secondAgent = supertest.agent(app)

    extractTokenFromCookie = (cookie)->
      cookie.match(/remember_me=([^;]+)/)[1]

    it 'should return a user when there is a remember me token set', (done)->
      @agent.jar.setCookies([@remember_me])
      @agent
        .get('/whoami')
        .expect(200)
        .end (err, res)->
          parsed = JSON.parse(res.text)
          expect(parsed.email).to.equal('test@dummy.com')
          done(err)


    it 'should create a new token for the user after consumed', (done)->
      oldRememberMeToken = extractTokenFromCookie(@remember_me)
      @secondAgent.jar.setCookies([@remember_me])
      @secondAgent
        .get('/whoami')
        .expect(200)
        .end (err, res)->
          newRememberMeToken = extractTokenFromCookie(res.headers['set-cookie'][0])
          expect(newRememberMeToken).not.to.equal(oldRememberMeToken)
          done(err)

  describe 'createNewToken', ->
    it 'should return a new token for the user id', (done)->
      user = new User
      RememberMe.createNewToken user, (err, token)->
        expect(err).to.be.null
        expect(token.length).to.equal(64)
        RememberMeToken.findOne token: token, (err, rmt)->
          expect(rmt._user.toString()).to.equal(user._id.toString())
          done(err)

  describe 'oneYear', ->
    it 'should equal one year in milliseconds', ->
      expect(RememberMe.createNewToken.oneYear).to.equal(31536000000)

loginUser = (agent, done)->
  onResponse = (err, res)->
    expect(res.statusCode).to.equal(200)
    expect(res.text).to.include('test@dummy.com')
    remember_me = res.headers['set-cookie'][0]
    return done(null, remember_me)

  agent
    .post('/login')
    .set('Accept', 'application/json')
    .send(username: 'test@dummy.com', password: 'spinach')
    .expect(200)
    .end(onResponse)
