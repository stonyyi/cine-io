supertest = require('supertest')
User = Cine.server_model('user')
Account = Cine.server_model('account')
Project = Cine.server_model('project')
app = Cine.require('app').app
engineyardConfig = Cine.config('variables/engineyard')
_ = require('underscore')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
crypto = require("crypto")
mongoose = require('mongoose')

describe 'engineyard authentication', ->
  constantAccountId = mongoose.Types.ObjectId()

  beforeEach ->
    @oldssoSalt = engineyardConfig.ssoSalt
    @oldusername = engineyardConfig.username
    @oldpassword = engineyardConfig.password
    engineyardConfig.ssoSalt = "test-ssoSalt"
    engineyardConfig.username = "test-username"
    engineyardConfig.password = "test-password"

  afterEach ->
    engineyardConfig.ssoSalt = @oldssoSalt
    engineyardConfig.username = @oldusername
    engineyardConfig.password = @oldpassword

  app.get '/whoami', (req, res)->
    res.send(req.currentUser)

  beforeEach ->
    @agent = supertest.agent(app)


  beforeEach (done)->
    @account = new Account(plans: ['free'], _id: constantAccountId)
    @account.save done

  beforeEach (done)->
    @user = new User
    @user._accounts.push(@account._id)
    @user.save done

  # User just added us on engineyard
  requiresEngineYardBasicAuth = (method, url, params={})->
    it 'requires engineyard sso basic_auth', (done)->
      @agent[method](url)
        .send(params)
        .expect(401)
        .end (err, res)->
          expect(res.text).to.equal('Authentication required')
          done(err)

  requiresSSOToken = (method, url, params={})->
    it 'requires engineyard sso token', (done)->
      @agent[method](url)
        .send(params)
        .expect(403)
        .end (err, res)->
          expect(res.text).to.equal('Token Mismatch')
          done(err)

  describe "post /engineyard/resources", ->
    params =
      ey_id: 9141
      name: 'cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp'
      invoices_url: 'https://addons.engineyard.com/api/2/provisioned_services/9141/invoices'
      callback_url: 'https://addons.engineyard.com/api/2/provisioned_services/9141'
      plan: 'solo'
      heroku_id: '9141-cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp'
      region: 'NA'
      options: {}
    requiresEngineYardBasicAuth('post', '/engineyard/resources', params)

    describe "success", ->

      assertEmailSent.admin "newUser"

      it 'creates a new user/project/plan', (done)->
        @agent
          .post('/engineyard/resources')
          .auth('test-username', 'test-password')
          .send(params)
          .expect(200)
          .end (err, res)->
            expect(err).to.be.null
            response = JSON.parse(res.text)
            expect(_.keys(response).sort()).to.deep.equal(['config', 'id', 'plan'])
            expect(response.plan).to.equal('solo')
            expect(_.keys(response.config).sort()).to.deep.equal(['CINE_IO_PUBLIC_KEY', 'CINE_IO_SECRET_KEY'])
            Account.findById response.id, (err, account)->
              expect(err).to.be.null
              expect(account.name).to.equal('cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp')
              expect(account.engineyardId).to.equal('9141-cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp')
              Project.find _account: account._id, (err, projects)->
                expect(err).to.be.null
                expect(projects).to.have.length(1)
                expect(projects[0].publicKey).to.equal(response.config.CINE_IO_PUBLIC_KEY)
                expect(projects[0].secretKey).to.equal(response.config.CINE_IO_SECRET_KEY)
                done()

  # User changed plan on engineyard
  describe "put /engineyard/resources/:id", ->
    params =
      plan: 'pro'

    requiresEngineYardBasicAuth('put', '/engineyard/resources/123')

    it 'updates the plan', (done)->
      @agent
        .put("/engineyard/resources/#{@account._id}")
        .auth('test-username', 'test-password')
        .send(params)
        .expect(200)
        .end (err, res)=>
          expect(err).to.be.null
          expect(res.text).to.equal('ok')
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.deletedAt).to.be.undefined
            expect(account.plans).to.have.length(1)
            expect(account.plans[0]).to.equal("pro")
            done()


  # User removed us from engineyard
  describe "delete /engineyard/resources/:id", ->
    requiresEngineYardBasicAuth('delete', '/engineyard/resources/123')

    it 'deletes the resource', (done)->
      @agent
        .delete("/engineyard/resources/#{@account._id}")
        .auth('test-username', 'test-password')
        .expect(200)
        .end (err, res)=>
          expect(err).to.be.null
          expect(res.text).to.equal('ok')
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.deletedAt).to.be.instanceOf(Date)
            done()


  describe 'EngineYard SSO', ->
    generateSSOParams = (method, account)->
      timestamp = (new Date).getTime()
      pre_token = "#{account._id}:test-ssoSalt:#{timestamp}"

      shasum = crypto.createHash("sha1")
      shasum.update pre_token
      token = shasum.digest("hex")
      params =
        token: token
        timestamp: timestamp
        email: 'some email'
        "nav-data": 'some-nav-data-that-gets-set-to-a-cookie'
      params.id = account._id if method == "post"
      params

    extractNavHeaderFromCookie = (cookie)->
      cookie.match(/engineyard-nav-data=([^;]+)/)[1]

    ssoCall = (method, url, done)->
      @agent[method](url)
        .send(generateSSOParams(method, @account))
        .expect(302)
        .end (err, res)=>
          console.log(err)
          expect(err).to.be.null
          @agent.saveCookies(res)
          @res = res
          process.nextTick ->
            done(err)

    ssoTests = (method, url)->
      requiresSSOToken method, url

      describe 'success', ->

        describe 'with a user who already has that email', ->
          beforeEach (done)->
            @user.email = 'some email'
            @user.save done

          beforeEach (done)->
            ssoCall.call(this, method, url, done)

          it "redirects to the homepage", ->
            expect(@res.headers.location).to.equal("/?accountId=#{constantAccountId}")

          it "sets some the engineyard-nav-data header", ->
            engineyardNavData = extractNavHeaderFromCookie(@res.headers['set-cookie'][0])
            expect(engineyardNavData).to.equal('some-nav-data-that-gets-set-to-a-cookie')

          it 'logs the user in', (done)->
            @agent.get('/whoami').expect(200).end (err, res)=>
              expect(err).to.be.null
              currentUser = JSON.parse(res.text)
              expect(currentUser.id.toString()).to.equal(@user._id.toString())
              done()

        describe 'with a new user to that account', ->
          beforeEach (done)->
            ssoCall.call(this, method, url, done)

          it 'adds email to a new user', (done)->
            User.findOne email: 'some email', (err, user)=>
              expect(err).to.be.null
              expect(user._accounts).to.have.length(1)
              expect(user._accounts[0].toString()).to.equal(@account._id.toString())
              done()

      describe 'verifying personal email', ->
        beforeEach (done)->
          @user.email = "original email"
          @user.save done

        beforeEach (done)->
          ssoCall.call(this, method, url, done)

        it 'does not overwrite an existing email', (done)->
          User.findById @user._id, (err, user)->
            expect(err).to.be.null
            expect(user.email).to.equal('original email')
            done()


    describe "get /engineyard/resources/:id", ->
      ssoTests('get', "/engineyard/resources/#{constantAccountId}")

    # definitely sso login
    describe "post /engineyard/sso", ->
      ssoTests('post', '/engineyard/sso')
