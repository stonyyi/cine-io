express = require('express')
Account = Cine.server_model('account')
User = Cine.server_model('user')
supertest = require('supertest')
qs = require('qs')
_str = require('underscore.string')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'

describe 'AppDirect/Subscription/Create', ->
  beforeEach ->
    @app = express()
    Cine.middleware('appdirect', @app)
    @agent = supertest.agent(@app)

  describe '/appdirect/create', ->

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
      @url = "/appdirect/create?#{qs.stringify(@appdirectParams)}"
      @validOauth = 'OAuth oauth_consumer_key="cineio-12056", oauth_nonce="1746785885757644257", oauth_signature="b77Je8pNvfmuP9PXltDrJXAVh9g%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1407971707", oauth_version="1.0"'

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

      describe 'with an already created user', ->
        beforeEach (done)->
          @user = new User(email: 'thomas@cine.io', plan: 'startup')
          @user.save done

        beforeEach ->
          @appDirectSuccessResponse = requireFixture('nock/appdirect_subscription_create_success')()

        assertEmailSent 'welcomeEmail'
        assertEmailSent.admin 'newUser'

        beforeEach (done)->
          getAppdirectUrl.call(this, done)

        it 'adds the account to the user', (done)->
          xml = _str.lines(@res.text).join(' ')
          accountId = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
          User.findById @user._id, (err, user)->
            expect(err).to.be.null
            expect(user._accounts).to.have.length(1)
            expect(user._accounts[0].toString()).to.equal(accountId)
            done()

        it 'creates an account', (done)->
          xml = _str.lines(@res.text).join(' ')
          expect(xml).to.include("<success>true</success>")
          accountId = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
          Account.findById accountId, (err, account)->
            expect(err).to.be.null
            expect(account.name).to.equal("cine.io")
            done()

    describe 'success', ->
      beforeEach ->
        @appDirectSuccessResponse = requireFixture('nock/appdirect_subscription_create_success')()

      assertEmailSent 'welcomeEmail'
      assertEmailSent.admin 'newUser'

      beforeEach (done)->
        getAppdirectUrl.call(this, done)

      it 'returns success', ->
        expect(@res.statusCode).to.equal(200)
        expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

      it 'sends the oauth headers to AppDirect', ->
        expect(@appDirectSuccessResponse.isDone()).to.be.true

      it 'creates an account', (done)->
        User.findOne email: 'thomas@cine.io', (err, user)->
          expect(err).to.be.null
          Account.findOne user._accounts[0], (err, account)->
            expect(err).to.be.null
            expect(account.name).to.equal('cine.io')
            expect(account.appdirectData.marketplace.partner).to.equal('CLOUDFOUNDRY')
            done()

      it 'creates a user', (done)->
        User.findOne email: 'thomas@cine.io', (err, user)->
          expect(err).to.be.null
          expect(user.name).to.equal("Thomas Shafer")
          expect(user.appdirectUUID).to.equal("5524eea2-00df-4a81-a4a9-57223a1fc5e6")
          expect(user.appdirectData.firstName).to.equal("Thomas")
          expect(user.appdirectData.lastName).to.equal("Shafer")
          done()

      it 'returns success and the correct identifier', (done)->
        xml = _str.lines(@res.text).join(' ')
        expect(xml).to.include("<success>true</success>")
        accountId = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
        Account.findById accountId, (err, account)->
          expect(err).to.be.null
          expect(account.name).to.equal("cine.io")
          done()
