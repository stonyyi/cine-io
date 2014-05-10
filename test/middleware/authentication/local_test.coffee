supertest = require('supertest')
User = SS.model('user')
app = SS.require('app').app
RememberMeToken = SS.model('remember_me_token')

describe 'local authentication', ->

  app.get '/whoami', (req, res)->
    res.send(req.currentUser)

  beforeEach resetMongo
  beforeEach ->
    @agent = supertest.agent(app)

  describe 'existing user', ->
    beforeEach (done)->
      @user = new User(email: 'the email')
      @user.assignHashedPasswordAndSalt 'the pass', (err)=>
        @user.save(done)

    it 'returns a user', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'the email', password: 'the pass')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          expect(response.email).to.equal('the email')
          done(err)


    it 'logs in the user', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'the email', password: 'the pass')
        .expect(200)
        .end (err, res)=>
          expect(err).to.be.null
          process.nextTick =>
            @agent.get('/whoami')
              .expect(200)
              .end (err, res)->
                expect(err).to.be.null
                response = JSON.parse(res.text)
                expect(response.email).to.equal('the email')
                done(err)

    it "errs if the passwords don't match", (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'the email', password: 'bad password')
        .expect(400)
        .end (err, res)->
          expect(res.text).to.equal('Incorrect email/password.')
          done(err)

    it 'issues a remember me token on success', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'the email', password: 'the pass')
        .expect(200)
        .end (err, res)=>
          remember_me = res.headers['set-cookie'][0]
          token = remember_me.match(/remember_me=([^;]+)/)[1]
          expect(token.length).to.equal(64)
          RememberMeToken.findOne token: token, (err, rmt)=>
            expect(rmt._user.toString()).to.equal(@user._id.toString())
            done(err)


  describe 'new user', ->
    it 'returns the user', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'new email', password: 'new pass')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          expect(response.email).to.equal('new email')
          done(err)

    it 'creates a new user', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'new email', password: 'new pass')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          User.findById response._id, (err, user)->
            expect(user.email).to.equal('new email')
            done(err)

    it 'gives that user a hashed_password and salt', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'new email', password: 'new pass')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          User.findById response._id, (err, user)->
            expect(user.hashed_password).not.to.be.null
            expect(user.password_salt).not.to.be.null
            done(err)

    it 'issues a remember me token', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'new email', password: 'new pass')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          remember_me = res.headers['set-cookie'][0]
          token = remember_me.match(/remember_me=([^;]+)/)[1]
          expect(token.length).to.equal(64)
          RememberMeToken.findOne token: token, (err, rmt)->
            expect(rmt._user.toString()).to.equal(response._id.toString())
            done(err)
