supertest = require('supertest')
User = Cine.server_model('user')
Account = Cine.server_model('account')
app = Cine.require('app').app
RememberMeToken = Cine.server_model('remember_me_token')
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
login = Cine.require 'test/helpers/login_helper'
expectSentryLog = Cine.require('test/helpers/expect_sentry_log')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'

describe 'local authentication', ->

  app.get '/whoami', (req, res)->
    res.send(req.currentUser)

  beforeEach ->
    @agent = supertest.agent(app)

  describe 'existing user', ->
    beforeEach (done)->
      @user = new User(email: 'the email', lastLoginIP: '999.888.777.666', createdAtIP: '111.222.333.444')
      @user.assignHashedPasswordAndSalt 'the pass', (err)=>
        @user.save(done)

    it 'returns a user', (done)->
      login @agent, @user, 'the pass', (err, res)->
        response = JSON.parse(res.text)
        expect(response.email).to.equal('the email')
        done(err)

    it 'saves the lastLoginIP on the user', (done)->
      login @agent, @user, 'the pass', (err, res)=>
        expect(err).to.be.null
        response = JSON.parse(res.text)
        User.findById @user._id, (err, user)->
          expect(err).to.be.null
          expect(user.lastLoginIP).to.equal('127.0.0.1')
          expect(user.createdAtIP).to.equal('111.222.333.444')
          done(err)

    it 'logs in the user', (done)->
      login @agent, @user, 'the pass', (err, res)=>
        @agent.get('/whoami')
          .expect(200)
          .end (err, res)->
            expect(err).to.be.null
            response = JSON.parse(res.text)
            expect(response.email).to.equal('the email')
            done(err)

    it 'issues a remember me token on success', (done)->
      login @agent, @user, 'the pass', (err, res)=>
        remember_me = res.headers['set-cookie'][0]
        token = remember_me.match(/remember_me=([^;]+)/)[1]
        expect(token.length).to.equal(64)
        RememberMeToken.findOne token: token, (err, rmt)=>
          expect(rmt._user.toString()).to.equal(@user._id.toString())
          done(err)

    describe 'failure', ->

      expectSentryLog()

      it "errs if the passwords don't match", (done)->
        @agent
          .post('/login')
          .set('X-Requested-With', 'XMLHttpRequest')
          .send(username: 'the email', password: 'bad password')
          .expect(401)
          .end (err, res)->
            expect(res.text).to.equal('Incorrect email/password.')
            done(err)


  describe 'new user', ->

    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'cines')
      @stream.save done

    stubEdgecast()

    assertEmailSent.admin 'newUser'

    it 'returns the user', (done)->
      login @agent, 'new email', 'new pass', 'broadcast-plan': 'solo', (err, res)->
        response = JSON.parse(res.text)
        expect(response.email).to.equal('new email')
        done(err)

    it 'creates a new user', (done)->
      login @agent, 'new email', 'new pass', 'broadcast-plan': 'free', (err, res)->
        response = JSON.parse(res.text)
        User.findById response.id, (err, user)->
          expect(user.email).to.equal('new email')
          done(err)

    it 'sets createdAtIP and lastLoginIP', (done)->
      login @agent, 'new email', 'new pass', 'broadcast-plan': 'free', (err, res)->
        response = JSON.parse(res.text)
        User.findById response.id, (err, user)->
          expect(user.lastLoginIP).to.equal('127.0.0.1')
          expect(user.createdAtIP).to.equal('127.0.0.1')
          done(err)

    it 'creates an account', (done)->
      login @agent, 'new email', 'new pass', 'broadcast-plan': 'free', (err, res)->
        response = JSON.parse(res.text)
        User.findById response.id, (err, user)->
          expect(err).to.be.null
          expect(user._accounts).to.have.length(1)
          Account.findById user._accounts[0], (err, account)->
            expect(err).to.be.null
            expect(account).to.be.ok
            done()

    it 'adds the correct billing provider', (done)->
      login @agent, 'new email', 'new pass', 'broadcast-plan': 'free', (err, res)->
        response = JSON.parse(res.text)
        User.findById response.id, (err, user)->
          expect(err).to.be.null
          expect(user._accounts).to.have.length(1)
          Account.findById user._accounts[0], (err, account)->
            expect(err).to.be.null
            expect(account.billingProvider).to.equal('cine.io')
            done()

    it 'gives that user a hashed_password and salt', (done)->
      login @agent, 'new email', 'new pass', 'broadcast-plan': 'free', (err, res)->
        response = JSON.parse(res.text)
        User.findById response.id, (err, user)->
          expect(user.hashed_password).to.be.ok
          expect(user.password_salt).to.be.ok
          done(err)

    it 'gives that account a broadcast plan', (done)->
      login @agent, 'new email', 'new pass', 'broadcast-plan': 'basic', (err, res)->
        response = JSON.parse(res.text)
        User.findById response.id, (err, user)->
          expect(err).to.be.null
          Account.findById user._accounts[0], (err, account)->
            expect(err).to.be.null
            expect(account.productPlans.peer).to.have.length(0)
            expect(account.productPlans.broadcast).to.have.length(1)
            expect(account.productPlans.broadcast[0]).to.equal('basic')
            done()

    it 'adds a project and a new stream to that user', (done)->
      login @agent, 'new email', 'new pass', 'broadcast-plan': 'free', (err, res)=>
        response = JSON.parse(res.text)
        User.findById response.id, (err, user)=>
          expect(err).to.be.null
          Account.findById user._accounts[0], (err, account)=>
            expect(err).to.be.null
            account.projects (err, projects)=>
              expect(err).to.be.null
              expect(projects).to.have.length(1)
              project = projects[0]
              expect(project.name).to.equal('First Project')
              EdgecastStream.find _project: project._id, (err, streams)=>
                expect(err).to.be.null
                expect(streams).to.have.length(1)
                expect(streams[0]._id.toString()).to.equal(@stream.id.toString())
                done()

    it 'issues a remember me token', (done)->
      login @agent, 'new email', 'new pass', 'broadcast-plan': 'free', (err, res)->
        response = JSON.parse(res.text)
        remember_me = res.headers['set-cookie'][0]
        token = remember_me.match(/remember_me=([^;]+)/)[1]
        expect(token.length).to.equal(64)
        RememberMeToken.findOne token: token, (err, rmt)->
          expect(rmt._user.toString()).to.equal(response.id.toString())
          done(err)

  describe 'new user with peer', ->

    assertEmailSent.admin 'newUser'

    it 'gives that account a peer plan', (done)->
      login @agent, 'new email', 'new pass', 'peer-plan': 'solo', (err, res)->
        response = JSON.parse(res.text)
        User.findById response.id, (err, user)->
          expect(err).to.be.null
          Account.findById user._accounts[0], (err, account)->
            expect(err).to.be.null
            expect(account.productPlans.broadcast).to.have.length(0)
            expect(account.productPlans.peer).to.have.length(1)
            expect(account.productPlans.peer[0]).to.equal('solo')
            done()
