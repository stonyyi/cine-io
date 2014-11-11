app = Cine.require('app').app
supertest = require('supertest')
login = Cine.require 'test/helpers/login_helper'
User = Cine.server_model('user')
parseUri = Cine.lib('parse_uri')
expectSentryLog = Cine.require('test/helpers/expect_sentry_log')

describe 'kue', ->
  beforeEach ->
    @agent = supertest.agent(app)


  describe 'failure', ->

    expectSentryLog()

    it 'requires a site admin', (done)->
      @agent
      .get('/admin/kue')
      .expect('Content-Type', /text\/plain; charset=UTF-8/)
      .expect(302)
      .end (err, res)->
        expect(err).to.be.null
        url = parseUri(res.headers.location)
        expect(url.path).to.equal('/401')
        expect(url.query).to.equal('originalUrl=/admin/kue')
        done()

    it 'requires a site admin for xhr requests', (done)->
      @agent
      .get('/admin/kue').set('X-Requested-With', 'xmlhttprequest')
      .expect('Content-Type', /application\/json; charset=utf-8/)
      .expect(401)
      .end done

  describe 'with a site admin', ->

    beforeEach (done)->
      @user = new User(email: 'some email', isSiteAdmin: true)
      @user.assignHashedPasswordAndSalt 'old pass', (err)=>
        @user.save(done)

    beforeEach (done)->
      login @agent, @user, 'old pass', done

    it 'serves the kue dashboard', (done)->
      @agent
      .get('/admin/kue')
      .expect('Content-Type', /text\/plain; charset=utf-8/)
      .expect(302)
      .end (err, res)->
        expect(err).to.be.null
        url = parseUri(res.headers.location)
        expect(url.path).to.equal('/admin/kue/active')
        done()

    it 'can handle ajax requests', (done)->
      @agent
      .get('/admin/kue/stats').set('X-Requested-With', 'xmlhttprequest')
      .expect('Content-Type', /application\/json; charset=utf-8/)
      .expect(200)
      .end (err, res)->
        expect(err).to.be.null
        actual = JSON.parse(res.text)
        expect(actual).to.deep.equal
          inactiveCount: 0
          completeCount: 0
          activeCount: 0
          failedCount: 0
          delayedCount: 0
          workTime: null
        done()
