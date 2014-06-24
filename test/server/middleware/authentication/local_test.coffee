supertest = require('supertest')
User = Cine.server_model('user')
app = Cine.require('app').app
RememberMeToken = Cine.server_model('remember_me_token')
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'

describe 'local authentication', ->

  app.get '/whoami', (req, res)->
    res.send(req.currentUser)

  beforeEach ->
    @agent = supertest.agent(app)

  describe 'existing user', ->
    beforeEach (done)->
      @user = new User(email: 'the email', plan: 'enterprise')
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

    it 'does not override the plan', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'the email', password: 'the pass', plan: 'startup')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          expect(response.plan).to.equal('enterprise')
          User.findById response.id, (err, user)->
            expect(user.plan).to.equal('enterprise')
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

    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'cines')
      @stream.save done

    stubEdgecast()

    it 'returns the user', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'new email', password: 'new pass', plan: 'solo')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          expect(response.email).to.equal('new email')
          done(err)

    it 'creates a new user', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'new email', password: 'new pass', plan: 'free')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          User.findById response.id, (err, user)->
            expect(user.email).to.equal('new email')
            done(err)

    it 'gives that user a hashed_password and salt', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'new email', password: 'new pass', plan: 'free')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          User.findById response.id, (err, user)->
            expect(user.hashed_password).not.to.be.null
            expect(user.password_salt).not.to.be.null
            done(err)

    it 'gives that user a plan', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'new email', password: 'new pass', plan: 'startup')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          expect(response.plan).to.equal('startup')
          User.findById response.id, (err, user)->
            expect(user.plan).to.equal('startup')
            done(err)

    it 'adds a project and a new stream to that user', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'new email', password: 'new pass', plan: 'free')
        .expect(200)
        .end (err, res)=>
          response = JSON.parse(res.text)
          User.findById response.id, (err, user)=>
            expect(err).to.be.null
            user.projects (err, projects)=>
              expect(err).to.be.null
              expect(projects).to.have.length(1)
              project = projects[0]
              expect(project.name).to.equal('Development')
              EdgecastStream.find _project: project._id, (err, streams)=>
                expect(err).to.be.null
                expect(streams).to.have.length(1)
                expect(streams[0]._id.toString()).to.equal(@stream.id.toString())
                done()

    it 'issues a remember me token', (done)->
      @agent
        .post('/login')
        .set('X-Requested-With', 'XMLHttpRequest')
        .send(username: 'new email', password: 'new pass', plan: 'free')
        .expect(200)
        .end (err, res)->
          response = JSON.parse(res.text)
          remember_me = res.headers['set-cookie'][0]
          token = remember_me.match(/remember_me=([^;]+)/)[1]
          expect(token.length).to.equal(64)
          RememberMeToken.findOne token: token, (err, rmt)->
            expect(rmt._user.toString()).to.equal(response.id.toString())
            done(err)
