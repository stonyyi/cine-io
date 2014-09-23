express = require('express')
Account = Cine.server_model('account')
User = Cine.server_model('user')
supertest = require('supertest')
qs = require('qs')
_str = require('underscore.string')

describe 'AppDirect/Users/Ununassign', ->
  beforeEach ->
    @app = express()
    Cine.middleware('appdirect', @app)
    @agent = supertest.agent(@app)

  describe '/appdirect/users/unassign', ->

    getAppdirectUrl = (done)->
      @agent
        .get(@url)
        .set('authorization', @validOauth)
        .end (err, res)=>
          @agent.saveCookies(res)
          @res = res
          process.nextTick ->
            done(err)

    beforeEach ->
      @appdirectParams =
        url: 'https://cloudfoundry.appdirect.com/api/integration/v1/events/2fe3a1c6-f10b-411c-94f1-de2794ff5c66'
        token: 'https://cloudfoundry.appdirect.com/api/integration/v1/events/2fe3a1c6-f10b-411c-94f1-de2794ff5c66'
      @url = "/appdirect/users/unassign?#{qs.stringify(@appdirectParams)}"
      @validOauth = 'OAuth oauth_consumer_key="cineio-12056", oauth_nonce="1746785885757644257", oauth_signature="O119p1i%2BmoS2L6JRX7vActpOb8E%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1407971707", oauth_version="1.0"'

    describe 'failure', ->

      it 'rejects when there are no oauth headers', (done)->
        @agent
          .get(@url)
          .expect(200)
          .end (err, res)->
            expect(err).to.be.null
            expect(res.text).to.include("<errorCode>UNAUTHORIZED</errorCode>")
            done()

      it 'rejects when the oauth headers from AppDirect are wrong', (done)->
        @agent
          .get(@url)
          .set('authorization', 'OAuth oauth_consumer_key="cineio-12056", oauth_nonce="1746785885757644257", oauth_signature="gdBQETGpsxHeYobQZ7YAoHFjW9Y%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1407971707", oauth_version="1.0"')
          .expect(200)
          .end (err, res)->
            expect(err).to.be.null
            expect(res.text).to.include("<errorCode>UNAUTHORIZED</errorCode>")
            done()

      describe 'with an appdirect error', ->
        beforeEach ->
          @appDirectErrorResponse = requireFixture('nock/appdirect_response_error')()

        beforeEach (done)->
          getAppdirectUrl.call(this, done)

        it 'can handle when the appdirect returns a bad result', ->
          expect(@res.statusCode).to.equal(200)
          expect(@res.text).to.include("<errorCode>INVALID_RESPONSE</errorCode>")

    describe 'without an account', ->

      beforeEach ->
        @appDirectSuccessResponse = requireFixture('nock/appdirect_unassign_user_success')((new Account)._id)

      beforeEach (done)->
        getAppdirectUrl.call(this, done)

      it 'returns success', ->
        expect(@res.statusCode).to.equal(200)
        expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

      it 'sends the oauth headers to AppDirect', ->
        expect(@appDirectSuccessResponse.isDone()).to.be.true

      it 'can handle when the appdirect returns a bad result', ->
        expect(@res.text).to.include("<success>false</success>")
        expect(@res.text).to.include("<errorCode>ACCOUNT_NOT_FOUND</errorCode>")

    describe 'with the account created and no user', ->

      beforeEach (done)->
        @account = new Account
        @account.save done

      beforeEach ->
        @appDirectSuccessResponse = requireFixture('nock/appdirect_unassign_user_success')(@account._id)

      beforeEach (done)->
        getAppdirectUrl.call(this, done)

      it 'returns success', ->
        expect(@res.statusCode).to.equal(200)
        expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

      it 'sends the oauth headers to AppDirect', ->
        expect(@appDirectSuccessResponse.isDone()).to.be.true

      it 'returns false with the correct error code', ->
        expect(@res.text).to.include("<success>false</success>")
        expect(@res.text).to.include("<errorCode>USER_NOT_FOUND</errorCode>")

    describe 'with the account created and the user already created', ->

      beforeEach (done)->
        @account = new Account
        @account.save done

      beforeEach (done)->
        @user = new User(email: 'jeffrey@cine.io', appdirectUUID: "9ef84c6f-bf89-41b5-90d8-1c1708d0140f")
        @user._accounts.push @account._id
        @user.save done

      beforeEach ->
        @appDirectSuccessResponse = requireFixture('nock/appdirect_unassign_user_success')(@account._id)

      beforeEach (done)->
        getAppdirectUrl.call(this, done)

      it 'returns success', ->
        expect(@res.statusCode).to.equal(200)
        expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

      it 'returns success true', ->
        xml = _str.lines(@res.text).join(' ')
        expect(xml).to.include("<success>true</success>")

      it 'sends the oauth headers to AppDirect', ->
        expect(@appDirectSuccessResponse.isDone()).to.be.true

      it 'removes the user from the account', (done)->
        User.findOne email: 'jeffrey@cine.io', (err, user)=>
          expect(err).to.be.null
          expect(user._id.toString()).to.equal(@user._id.toString())
          expect(user._accounts).to.have.length(0)
          done()
