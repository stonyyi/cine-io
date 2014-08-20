app = Cine.require('app').app
test = require('supertest')
User = Cine.server_model('user')
expectSentryLog = Cine.require('test/helpers/expect_sentry_log')

describe 'login', ->
  beforeEach (done)->
    @user = new User(email: 'the email')
    @user.assignHashedPasswordAndSalt 'the pass', (err)=>
      @user.save(done)

  expectSentryLog()

  it 'should return a useful response instead of 400', (done)->
    params =  username: 'the email', password: 'wrong pass'
    test(app)
    .post('/login')
    .set('X-Requested-With', 'XMLHttpRequest')
    .set('Accept', 'application/json')
    .send(params)
    .expect(401)
    .end (err, res)->
      expect(err).to.be.null
      expect(res.text).to.equal('Incorrect email/password.')
      done()
