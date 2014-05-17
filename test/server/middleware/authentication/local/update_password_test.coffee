supertest = require('supertest')
User = Cine.server_model('user')
app = Cine.require('app').app
RememberMeToken = Cine.server_model('remember_me_token')
PasswordChangeRequest = Cine.server_model 'password_change_request'

describe 'update password', ->

  app.get '/whoami', (req, res)->
    res.send(req.currentUser)

  beforeEach ->
    @agent = supertest.agent(app)

  describe 'failure states', ->
    it 'requires an identifier', (done)->
      @agent
        .post('/update-password')
        .expect(400)
        .end (err, res)->
          expect(res.text).to.equal('missing identifier')
          done(err)

    it 'requires a new password', (done)->
      @agent
        .post('/update-password')
        .send(identifier: 'my ident')
        .expect(400)
        .end (err, res)->
          expect(res.text).to.equal('missing password')
          done(err)

    it 'must have a saved PasswordChangeRequest', (done)->
      @agent
        .post('/update-password')
        .send(identifier: 'my ident', password: 'new pass')
        .expect(400)
        .end (err, res)->
          expect(res.text).to.equal('token not found')
          done(err)

    describe 'with data', ->
      beforeEach (done)->
        @pcr = new PasswordChangeRequest()
        @pcr.save(done)

      it 'must have a user associated with the PasswordChangeRequest', (done)->
        @agent
          .post('/update-password')
          .send(identifier: @pcr.identifier, password: 'new pass')
          .expect(400)
          .end (err, res)->
            expect(res.text).to.equal('invalid token')
            done(err)

  describe 'success states', ->
    beforeEach (done)->
      @user = new User(email: 'some email')
      @user.assignHashedPasswordAndSalt 'old pass', (err)=>
        @user.save(done)

    beforeEach (done)->
      @pcr = new PasswordChangeRequest(_user: @user._id)
      @pcr.save(done)

    it 'redirects home', (done)->
      @agent
        .post('/update-password')
        .send(identifier: @pcr.identifier, password: 'new pass')
        .expect(200)
        .end (err, res)->
          expect(JSON.parse(res.text)).to.deep.equal(redirect: '/')
          done(err)

    it 'updates the password on the user', (done)->
      @agent
        .post('/update-password')
        .send(identifier: @pcr.identifier, password: 'new pass')
        .expect(200)
        .end (err, res)=>
          User.findById @user._id, (err, user)->
            user.isCorrectPassword 'new pass', done
    it 'logs in the user', (done)->
      @agent
        .post('/update-password')
        .send(identifier: @pcr.identifier, password: 'new pass')
        .expect(200)
        .end (err, res)=>
          process.nextTick =>
            @agent.get('/whoami')
              .expect(200)
              .end (err, res)=>
                response = JSON.parse(res.text)
                expect(response.email).to.equal('some email')
                expect(response.id.toString()).to.equal(@user._id.toString())
                done(err)

    it 'creates a remember_me token', (done)->
      @agent
        .post('/update-password')
        .send(identifier: @pcr.identifier, password: 'new pass')
        .expect(200)
        .end (err, res)=>
          remember_me = res.headers['set-cookie'][0]
          token = remember_me.match(/remember_me=([^;]+)/)[1]
          expect(token.length).to.equal(64)
          RememberMeToken.findOne token: token, (err, rmt)=>
            expect(rmt._user.toString()).to.equal(@user._id.toString())
            done(err)
