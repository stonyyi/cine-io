EnsureSiteAdmin = Cine.middleware('ensure_site_admin')
supertest = require('supertest')
User = Cine.server_model('user')
app = Cine.require('app').app
parseUri = Cine.lib('parse_uri')
qs = require('qs')
login = Cine.require 'test/helpers/login_helper'
expectSentryLog = Cine.require('test/helpers/expect_sentry_log')

describe 'EnsureSiteAdmin', ->

  app.get '/admin-test', EnsureSiteAdmin, (req, res)->
    res.send(200, 'success!')
  # need to add error_handling after this new route
  app.use Cine.middleware('error_handling')

  beforeEach ->
    @agent = supertest.agent(app)

  beforeEach (done)->
    @user = new User(email: 'some email')
    @user.assignHashedPasswordAndSalt 'old pass', (err)=>
      @user.save(done)

  describe 'xhr', ->
    describe "failure", ->
      expectSentryLog()

      it 'returns 401 when not logged in', (done)->
        @agent.get('/admin-test').set('X-Requested-With', 'xmlhttprequest').expect(401).end done

      it 'returns 401 when the user is not a site admin', (done)->
        login @agent, @user, 'old pass', =>
          @agent.get('/admin-test').set('X-Requested-With', 'xmlhttprequest').expect(401).end done

    it 'continues when the user is a site admin', (done)->
      @user.isSiteAdmin = true
      @user.save (err, user)=>
        expect(err).to.be.null
        login @agent, @user, 'old pass', =>
          @agent.get('/admin-test').set('X-Requested-With', 'xmlhttprequest').expect(200).end(done)

  describe 'html', ->
    describe "failure", ->
      expectSentryLog()

      it 'returns 401 when not logged in', (done)->
        @agent.get('/admin-test').expect(302).end (err, res)->
          expect(err).to.be.null
          url = parseUri(res.headers.location)
          expect(url.path).to.equal('/401')
          params = qs.parse(url.query)
          expect(params.originalUrl).to.equal('/admin-test')
          done()

      it 'returns 401 when the user is not a site admin', (done)->
        login @agent, @user, 'old pass', =>
          @agent.get('/admin-test').expect(302).end (err, res)->
            expect(err).to.be.null
            url = parseUri(res.headers.location)
            expect(url.path).to.equal('/401')
            params = qs.parse(url.query)
            expect(params.originalUrl).to.equal('/admin-test')
            done()

    it 'continues when the user is a site admin', (done)->
      @user.isSiteAdmin = true
      @user.save (err, user)=>
        expect(err).to.be.null
        login @agent, @user, 'old pass', =>
          @agent.get('/admin-test').expect(200).end(done)
