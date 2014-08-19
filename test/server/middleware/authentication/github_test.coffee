supertest = require('supertest')
User = Cine.server_model('user')
BillingProvider = Cine.server_model('billing_provider')
Account = Cine.server_model('account')
app = Cine.require('app').app
_ = require('underscore')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
RememberMeToken = Cine.server_model('remember_me_token')
requiresSeed = Cine.require 'test/helpers/requires_seed'

describe 'github auth', ->

  beforeEach ->
    @agent = supertest.agent(app)

  app.get '/whoami', (req, res)->
    res.send(req.currentUser)

  describe '/auth/github', ->

    it 'redirects to github', (done)->
      @agent
        .get('/auth/github?plan=startup&client=web')
        .expect(302)
        .end (err, res)->
          expect(res.headers.location).to.equal("https://github.com/login/oauth/authorize?response_type=code&redirect_uri=&scope=user%3Aemail&state=%7B%22plan%22%3A%22startup%22%2C%22client%22%3A%22web%22%7D&client_id=0970d704f4137ab1e8a1")
          expect(res.text).to.equal("Moved Temporarily. Redirecting to https://github.com/login/oauth/authorize?response_type=code&redirect_uri=&scope=user%253Aemail&state=%257B%2522plan%2522%253A%2522startup%2522%252C%2522client%2522%253A%2522web%2522%257D&client_id=0970d704f4137ab1e8a1")
          done(err)

  describe '/auth/github/callback', ->
    beforeEach ->
      @oauthResponseNock = requireFixture('nock/github_oauth_response_with_access_token')()

    afterEach ->
      expect(@oauthResponseNock.isDone()).to.be.true
      expect(@profileDataNock.isDone()).to.be.true

    describe "with a new user", ->

      assertEmailSent 'welcomeEmail'
      assertEmailSent.admin 'newUser'

      requiresSeed()

      beforeEach (done)->
        @stream = new EdgecastStream(streamName: 'name1')
        @stream.save(done)

      stubEdgecast()

      describe 'with a new user who has a public email in github', ->
        beforeEach ->
          @profileDataNock = requireFixture('nock/github_oauth_user_response_with_email')()

        beforeEach (done)->
          @agent
            .get('/auth/github/callback?code=f82d92e61bf7f1605066&state=%7B"plan"%3A"startup"%2C"client"%3A"web"%7D')
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
              expect(account.tempPlan).to.equal('startup')
              done()

        it 'adds the correct billing provider', (done)->
          User.findOne githubId: 135461, (err, user)->
            expect(err).to.be.null
            expect(user._accounts).to.have.length(1)
            Account.findById user._accounts[0], (err, account)->
              expect(err).to.be.null
              BillingProvider.findById account._billingProvider, (err, provider)->
                expect(err).to.be.null
                expect(provider.name).to.equal('cine.io')
                done()

        it 'redirects to the homepage', ->
          expect(@res.headers.location).to.equal("/")
          expect(@res.text).to.equal("Moved Temporarily. Redirecting to /")

        it 'creates a new user', (done)->
          User.findOne githubId: 135461, (err, user)->
            expect(err).to.be.null
            expect(user.name).to.equal("Thomas Shafer")
            expect(user.email).to.equal("thomas@givingstage.com")
            expect(user.githubAccessToken).to.equal("5b375ac2ddd691be9a8468877ea38ad3ba86f440")
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
            .get('/auth/github/callback?code=f82d92e61bf7f1605066&state=%7B"plan"%3A"startup"%2C"client"%3A"web"%7D')
            .expect(302)
            .end (err, res)=>
              @agent.saveCookies(res)
              @res = res
              process.nextTick ->
                done(err)
        afterEach ->
          expect(@userEmailsNock.isDone()).to.be.true

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

        beforeEach (done)->
          @agent
            .get('/auth/github/callback?code=f82d92e61bf7f1605066&state=%7B"plan"%3A"startup"%2C"client"%3A"web"%7D')
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

      beforeEach (done)->
        @user = new User(plan: 'startup', githubId: 135461, email: 'orig email', name: 'my name')
        @user.save done

      beforeEach (done)->
        @agent
          .get('/auth/github/callback?code=f82d92e61bf7f1605066&state=%7B"plan"%3A"startup"%2C"client"%3A"web"%7D')
          .expect(302)
          .end (err, res)=>
            @agent.saveCookies(res)
            @res = res
            process.nextTick ->
              done(err)

      it 'redirects to the homepage', ->
        expect(@res.headers.location).to.equal("/")
        expect(@res.text).to.equal("Moved Temporarily. Redirecting to /")

      it 'only changes the githubData and githubAccessToken', (done)->
        User.findOne githubId: 135461, (err, user)->
          expect(err).to.be.null
          expect(user.name).to.equal("my name")
          expect(user.email).to.equal("orig email")
          expect(user.githubAccessToken).to.equal("5b375ac2ddd691be9a8468877ea38ad3ba86f440")
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

      beforeEach (done)->
        @agent
          .get('/auth/github/callback?code=f82d92e61bf7f1605066&state=%7B"plan"%3A"startup"%2C"client"%3A"iOS"%7D')
          .expect(302)
          .end (err, res)=>
            @agent.saveCookies(res)
            @res = res
            process.nextTick ->
              done(err)

      it 'redirects to the iOS client with the masterKey', (done)->
        @agent.get('/whoami').expect(200).end (err, res)=>
          expect(err).to.be.null
          currentUser = JSON.parse(res.text)
          expect(currentUser.masterKey).to.have.length(64)
          expect(@res.headers.location).to.equal("cineioconsole://login?masterKey=#{currentUser.masterKey}")
          expect(@res.text).to.equal("Moved Temporarily. Redirecting to cineioconsole://login?masterKey=#{currentUser.masterKey}")
          done()
