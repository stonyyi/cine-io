supertest = require('supertest')
mainApp = Cine.require('app').app
ErrorHandling = Cine.middleware('error_handling')
express = require('express')
parseUri = Cine.lib('parse_uri')
qs = require('qs')
expectSentryLog = Cine.require('test/helpers/expect_sentry_log')
bodyParser = require('body-parser')
methodOverride = require('method-override')


describe 'ErrorHandling', ->
  beforeEach ->
    app = express()
    app.use(bodyParser.urlencoded(extended: false))
    app.use(bodyParser.json())
    app.use(methodOverride())
    app.get '/serve-me-a-404', (req, res, next)->
      error = {message: 'some 404 problem', status: 404}
      # error = new Error('some 404 problem')
      # error.status = 404
      next(error)
    app.get '/serve-me-a-400', (req, res, next)->
      error = message: 'some problem'
      next(error)

    app.get '/serve-me-a-401', (req, res, next)->
      error = message: 'some problem', status: 401
      next(error)

    app.use ErrorHandling
    @agent = supertest.agent(app)

  expectSentryLog()

  describe 'xhr requests', ->
    it 'serves the error back to me', (done)->
      @agent
        .get('/serve-me-a-404')
        .set('X-Requested-With', 'XMLHttpRequest')
        .expect(404).end (err, res)->
          response = JSON.parse res.text
          expect(response).to.deep.equal(message: "some 404 problem", status: 404)
          done()

    it 'defaults to a 400', (done)->
      @agent
        .get('/serve-me-a-400')
        .set('X-Requested-With', 'XMLHttpRequest')
        .expect(400).end (err, res)->
          response = JSON.parse res.text
          expect(response).to.deep.equal(message: "some problem")
          done()

  describe 'html requests', ->
    it 'serves me the 404 page', (done)->
      @agent.get('/serve-me-a-404').expect(404).end (err, res)->
        expect(err).to.be.null
        expect(res.text).to.include("We can't find what you're looking for.")
        done()

    it 'serves me the 400 page', (done)->
      @agent.get('/serve-me-a-400').expect(400).end (err, res)->
        expect(err).to.be.null
        expect(res.text).to.include("An unknown error has occured.")
        done()
    it 'serves me the 401 page', (done)->
      @agent.get('/serve-me-a-401').expect(302).end (err, res)->
        url = parseUri(res.headers.location)
        expect(url.path).to.equal('/401')
        params = qs.parse(url.query)
        expect(params.originalUrl).to.equal('/serve-me-a-401')
        done()
