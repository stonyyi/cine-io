supertest = require('supertest')
User = Cine.server_model('user')
Account = Cine.server_model('account')
app = Cine.require('app').app
_ = require('underscore')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
RememberMeToken = Cine.server_model('remember_me_token')

describe 'github auth', ->

  beforeEach ->
    @agent = supertest.agent(app)

  app.get '/whoami', (req, res)->
    res.send(req.currentUser)

  describe '/auth/github', ->

    it 'redirects to github', (done)->
      @agent
        .get('/auth/github?broadcast-plan=solo&peer-plan=basic&client=web')
        .expect(302)
        .end (err, res)->
          expect(res.headers.location).to.equal("https://github.com/login/oauth/authorize?response_type=code&redirect_uri=&scope=user%3Aemail&state=%7B%22broadcastPlan%22%3A%22solo%22%2C%22peerPlan%22%3A%22basic%22%2C%22client%22%3A%22web%22%7D&client_id=0970d704f4137ab1e8a1")
          expect(res.text).to.equal("")
          done(err)

    it 'redirects to github with the old style plans', (done)->
      @agent
        .get('/auth/github?plan=solo&client=web')
        .expect(302)
        .end (err, res)->
          expect(res.headers.location).to.equal("https://github.com/login/oauth/authorize?response_type=code&redirect_uri=&scope=user%3Aemail&state=%7B%22broadcastPlan%22%3A%22solo%22%2C%22client%22%3A%22web%22%7D&client_id=0970d704f4137ab1e8a1")
          expect(res.text).to.equal("")
          done(err)

  describe '/auth/github/callback', ->
    beforeEach ->
      @oauthResponseNock = requireFixture('nock/github_oauth_response_with_access_token')()

    afterEach ->
      expect(@oauthResponseNock.isDone()).to.be.true

    describe "with a new user", ->

      assertEmailSent 'welcomeEmail'
      assertEmailSent.admin 'newUser'

      beforeEach (done)->
        @stream = new EdgecastStream(streamName: 'name1')
        @stream.save(done)

      stubEdgecast()

      describe 'with a new user who has a public email in github', ->
        beforeEach ->
          @profileDataNock = requireFixture('nock/github_oauth_user_response_with_email')()

        afterEach ->
          expect(@profileDataNock.isDone()).to.be.true

        beforeEach (done)->
          @agent
            .get('/auth/github/callback?code=f82d92e61bf7f1605066&state=%7B"broadcastPlan"%3A"basic"%2C"peerPlan"%3A"solo"%2C"client"%3A"web"%7D')
            .expect(302)
            .end (err, res)=>
              @agent.saveCookies(res)
              @res = res
              process.nextTick ->
                done(err)

        it 'creates an account', (done)->
          User.findOne githubId: 135461, (err, user)->
            expect(err).to.be.null
            expect(user._accounts).to.have.length(1)
            Account.findById user._accounts[0], (err, account)->
              expect(err).to.be.null
              expect(account.productPlans.peer).to.have.length(1)
              expect(account.productPlans.peer[0]).to.equal('solo')
              expect(account.productPlans.broadcast).to.have.length(1)
              expect(account.productPlans.broadcast[0]).to.equal('basic')
              done()

        it 'adds the correct billing provider', (done)->
          User.findOne githubId: 135461, (err, user)->
            expect(err).to.be.null
            expect(user._accounts).to.have.length(1)
            Account.findById user._accounts[0], (err, account)->
              expect(err).to.be.null
              expect(account.billingProvider).to.equal('cine.io')
              done()

        it 'redirects to the dashboard', ->
          expect(@res.headers.location).to.equal("/dashboard")
          expect(@res.text).to.equal("Moved Temporarily. Redirecting to /dashboard")

        it 'creates a new user', (done)->
          User.findOne githubId: 135461, (err, user)->
            expect(err).to.be.null
            expect(user.name).to.equal("Thomas Shafer")
            expect(user.email).to.equal("thomas@givingstage.com")
            expect(user.githubAccessToken).to.equal("5b375ac2ddd691be9a8468877ea38ad3ba86f440")
            done()

        it 'sets createdAtIP and lastLoginIP', (done)->
          User.findOne githubId: 135461, (err, user)->
            expect(err).to.be.null
            expect(user.lastLoginIP).to.equal('127.0.0.1')
            expect(user.createdAtIP).to.equal('127.0.0.1')
            done()

        it 'logs the user in', (done)->
          @agent.get('/whoami').expect(200).end (err, res)->
            currentUser = JSON.parse(res.text)
            expect(currentUser.githubId).to.equal(135461)
            done()

        it 'adds a project and default stream', (done)->
          User.findOne githubId: 135461, (err, user)=>
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

        it 'sets a remember me token', (done)->
          remember_me = @res.headers['set-cookie'][0]
          token = remember_me.match(/remember_me=([^;]+)/)[1]
          expect(token.length).to.equal(64)
          @agent.get('/whoami').expect(200).end (err, res)->
            currentUser = JSON.parse(res.text)
            RememberMeToken.findOne token: token, (err, rmt)->
              expect(rmt._user.toString()).to.equal(currentUser.id.toString())
              done(err)

      describe 'with a new user who does not have a public email in github', ->

        beforeEach ->
          @profileDataNock = requireFixture('nock/github_oauth_user_response_without_email')()
          @userEmailsNock = requireFixture('nock/github_user_emails_response')()

        beforeEach (done)->
          @agent
            .get('/auth/github/callback?code=f82d92e61bf7f1605066&state=%7B"broadcastPlan"%3A"basic"%2C"peerPlan"%3A"solo"%2C"client"%3A"web"%7D')
            .expect(302)
            .end (err, res)=>
              @agent.saveCookies(res)
              @res = res
              process.nextTick ->
                done(err)
        afterEach ->
          expect(@userEmailsNock.isDone()).to.be.true
          expect(@profileDataNock.isDone()).to.be.true

        it 'fetches the private email from github', (done)->
          User.findOne githubId: 135461, (err, user)->
            expect(err).to.be.null
            expect(user.name).to.equal("Thomas Shafer")
            expect(user.email).to.equal("thomasjshafer@gmail.com")
            expect(user.githubAccessToken).to.equal("5b375ac2ddd691be9a8468877ea38ad3ba86f440")
            done()

      describe 'with a new user who does not have a public name', ->

        beforeEach ->
          @profileDataNock = requireFixture('nock/github_oauth_user_response_with_email_but_no_name')()

        afterEach ->
          expect(@profileDataNock.isDone()).to.be.true

        beforeEach (done)->
          @agent
            .get('/auth/github/callback?code=f82d92e61bf7f1605066&state=%7B"plan"%3A"basic"%2C"client"%3A"web"%7D')
            .expect(302)
            .end (err, res)=>
              @agent.saveCookies(res)
              @res = res
              process.nextTick ->
                done(err)
        it 'uses the login from github as the name', (done)->
          User.findOne githubId: 135461, (err, user)->
            expect(err).to.be.null
            expect(user.name).to.equal("growlypants")
            expect(user.email).to.equal("thomas@givingstage.com")
            expect(user.githubAccessToken).to.equal("5b375ac2ddd691be9a8468877ea38ad3ba86f440")
            done()

    describe "with an existing user", ->
      beforeEach ->
        @profileDataNock = requireFixture('nock/github_oauth_user_response_with_email')()

      afterEach ->
        expect(@profileDataNock.isDone()).to.be.true

      beforeEach (done)->
        @user = new User(githubId: 135461, email: 'orig email', name: 'my name', lastLoginIP: '999.888.777.666', createdAtIP: '111.222.333.444')
        @user.save done

      beforeEach (done)->
        @agent
          .get('/auth/github/callback?code=f82d92e61bf7f1605066&state=%7B"plan"%3A"basic"%2C"client"%3A"web"%7D')
          .expect(302)
          .end (err, res)=>
            @agent.saveCookies(res)
            @res = res
            process.nextTick ->
              done(err)

      it 'redirects to the dashboard', ->
        expect(@res.headers.location).to.equal("/dashboard")
        expect(@res.text).to.equal("Moved Temporarily. Redirecting to /dashboard")

      it 'just changes the githubData and githubAccessToken', (done)->
        User.findOne githubId: 135461, (err, user)->
          expect(err).to.be.null
          expect(user.name).to.equal("my name")
          expect(user.email).to.equal("orig email")
          expect(user.githubAccessToken).to.equal("5b375ac2ddd691be9a8468877ea38ad3ba86f440")
          done()

      it 'sets lastLoginIP', (done)->
        User.findOne githubId: 135461, (err, user)->
          expect(err).to.be.null
          expect(user.createdAtIP).to.equal('111.222.333.444')
          expect(user.lastLoginIP).to.equal('127.0.0.1')
          done()

      it 'logs the user in', (done)->
        @agent.get('/whoami').expect(200).end (err, res)=>
          currentUser = JSON.parse(res.text)
          expect(currentUser.githubId).to.equal(135461)
          expect(currentUser.id.toString()).to.equal(@user._id.toString())
          done()

      it 'does not add an account', (done)->
        User.findOne githubId: 135461, (err, user)->
          expect(err).to.be.null
          expect(user._accounts).to.have.length(0)
          done()

      it 'sets a remember me token', (done)->
        remember_me = @res.headers['set-cookie'][0]
        token = remember_me.match(/remember_me=([^;]+)/)[1]
        expect(token.length).to.equal(64)
        @agent.get('/whoami').expect(200).end (err, res)->
          currentUser = JSON.parse(res.text)
          RememberMeToken.findOne token: token, (err, rmt)->
            expect(rmt._user.toString()).to.equal(currentUser.id.toString())
            done(err)

    describe 'with an iOS client', ->

      assertEmailSent 'welcomeEmail'
      assertEmailSent.admin 'newUser'

      beforeEach ->
        @profileDataNock = requireFixture('nock/github_oauth_user_response_with_email')()

      afterEach ->
        expect(@profileDataNock.isDone()).to.be.true

      beforeEach (done)->
        @agent
          .get('/auth/github/callback?code=f82d92e61bf7f1605066&state=%7B"plan"%3A"basic"%2C"client"%3A"iOS"%7D')
          .expect(302)
          .end (err, res)=>
            @agent.saveCookies(res)
            @res = res
            process.nextTick ->
              done(err)

      it 'redirects to the iOS client with the userToken', (done)->
        @agent.get('/whoami').expect(200).end (err, res)=>
          expect(err).to.be.null
          currentUser = JSON.parse(res.text)
          expect(currentUser.userToken).to.have.length(64)
          expect(@res.headers.location).to.equal("cineioconsole://login?userToken=#{currentUser.userToken}")
          expect(@res.text).to.equal("Moved Temporarily. Redirecting to cineioconsole://login?userToken=#{currentUser.userToken}")
          done()
