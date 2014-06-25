supertest = require('supertest')
User = Cine.server_model('user')
app = Cine.require('app').app
herokuConfig = Cine.config('variables/heroku')
_ = require('underscore')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
crypto = require("crypto")

describe 'heroku authentication', ->
  beforeEach ->
    @oldssoSalt = herokuConfig.ssoSalt
    @oldusername = herokuConfig.username
    @oldpassword = herokuConfig.password
    herokuConfig.ssoSalt = "test-ssoSalt"
    herokuConfig.username = "test-username"
    herokuConfig.password = "test-password"

  afterEach ->
    herokuConfig.ssoSalt = @oldssoSalt
    herokuConfig.username = @oldusername
    herokuConfig.password = @oldpassword

  app.get '/whoami', (req, res)->
    res.send(req.currentUser)

  beforeEach ->
    @agent = supertest.agent(app)

  beforeEach (done)->
    @user = new User(plan: 'free')
    @user.save done

  # User just added us on heroku
  requiresHerokuBasicAuth = (method, url, params={})->
    it 'requires heroku sso basic_auth', (done)->
      @agent[method](url)
        .send(params)
        .expect(401)
        .end (err, res)->
          expect(res.text).to.equal('Authentication required')
          done(err)

  requiresSSOToken = (method, url, params={})->
    it 'requires heroku sso token', (done)->
      @agent[method](url)
        .send(params)
        .expect(403)
        .end (err, res)->
          expect(res.text).to.equal('Token Mismatch')
          done(err)

  describe "post /heroku/resources", ->
    params =
      heroku_id: 'app123@heroku.com'
      plan: 'startup'
    requiresHerokuBasicAuth('post', '/heroku/resources', params)

    describe "success", ->

      assertEmailSent.admin "newUser"

      it 'creates a new user/project/plan', (done)->
        @agent
          .post('/heroku/resources')
          .auth('test-username', 'test-password')
          .send(params)
          .expect(200)
          .end (err, res)->
            expect(err).to.be.null
            response = JSON.parse(res.text)
            expect(_.keys(response).sort()).to.deep.equal(['config', 'id', 'plan'])
            expect(response.plan).to.equal('startup')
            expect(_.keys(response.config).sort()).to.deep.equal(['CINE_IO_PUBLIC_KEY', 'CINE_IO_SECRET_KEY'])
            User.findById response.id, (err, user)->
              expect(err).to.be.null
              expect(user.email).to.equal("app123@heroku.com")
              user.projects (err, projects)->
                expect(err).to.be.null
                expect(projects).to.have.length(1)
                expect(projects[0].publicKey).to.equal(response.config.CINE_IO_PUBLIC_KEY)
                expect(projects[0].secretKey).to.equal(response.config.CINE_IO_SECRET_KEY)
                done()

  # User changed plan on heroku
  describe "put /heroku/resources/:id", ->
    params =
      plan: 'enterprise'

    requiresHerokuBasicAuth('put', '/heroku/resources/123')

    it 'updates the plan', (done)->
      @agent
        .put("/heroku/resources/#{@user._id}")
        .auth('test-username', 'test-password')
        .send(params)
        .expect(200)
        .end (err, res)=>
          expect(err).to.be.null
          expect(res.text).to.equal('ok')
          User.findById @user._id, (err, user)->
            expect(err).to.be.null
            expect(user.deletedAt).to.be.undefined
            expect(user.plan).to.equal("enterprise")
            done()


  # User removed us from heroku
  describe "delete /heroku/resources/:id", ->
    requiresHerokuBasicAuth('delete', '/heroku/resources/123')

    it 'updates the plan', (done)->
      @agent
        .delete("/heroku/resources/#{@user._id}")
        .auth('test-username', 'test-password')
        .expect(200)
        .end (err, res)=>
          expect(err).to.be.null
          expect(res.text).to.equal('ok')
          User.findById @user._id, (err, user)->
            expect(err).to.be.null
            expect(user.deletedAt).to.be.instanceOf(Date)
            done()


  describe 'Heroku SSO', ->
    generateSSOParams = (method, user)->
      timestamp = (new Date).getTime()
      pre_token = "#{user._id}:test-ssoSalt:#{timestamp}"

      shasum = crypto.createHash("sha1")
      shasum.update pre_token
      token = shasum.digest("hex")
      params =
        token: token
        timestamp: timestamp
        email: 'some email'
        "nav-data": 'some-nav-data-that-gets-set-to-a-cookie'
      params.id = user._id if method == "post"
      params

    # ??? - maybe SSO login
    extractTokenFromCookie = (cookie)->
      cookie.match(/heroku-nav-data=([^;]+)/)[1]


    ssoCall = (method, url, done)->
      @agent[method](url)
        .send(generateSSOParams(method, @user))
        .expect(302)
        .end (err, res)=>
          @agent.saveCookies(res)
          @res = res
          process.nextTick ->
            done(err)

    ssoTests = ->
      it "redirects to the homepage", ->
        expect(@res.headers.location).to.equal('/')

      it "sets some the heroku-nav-data header", ->
        herokuNavData = extractTokenFromCookie(@res.headers['set-cookie'][0])
        expect(herokuNavData).to.equal('some-nav-data-that-gets-set-to-a-cookie')

      it 'logs the user in', (done)->
        @agent.get('/whoami').expect(200).end (err, res)=>
          currentUser = JSON.parse(res.text)
          expect(currentUser.id.toString()).to.equal(@user._id.toString())
          done()

    describe "get /heroku/resources/:id", ->
      requiresSSOToken 'get', '/heroku/resources/123'

      describe 'success', ->
        beforeEach (done)->
          ssoCall.call(this, 'get', "/heroku/resources/#{@user._id}", done)

        ssoTests()

    # definitely sso login
    describe "post /heroku/sso", ->
      requiresSSOToken 'post', '/heroku/sso'

      describe 'success', ->
        beforeEach (done)->
          ssoCall.call(this, 'post', '/heroku/sso', done)
        ssoTests()
