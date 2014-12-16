express = require('express')
Account = Cine.server_model('account')
supertest = require('supertest')
qs = require('qs')
_str = require('underscore.string')

describe 'AppDirect/Subscription/Notice', ->
  beforeEach ->
    @app = express()
    Cine.middleware('appdirect', @app)
    @agent = supertest.agent(@app)

  describe '/appdirect/notice', ->

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
      @url = "/appdirect/notice?#{qs.stringify(@appdirectParams)}"
      @validOauth = 'OAuth oauth_consumer_key="cineio-12056", oauth_nonce="1746785885757644257", oauth_signature="pHVOmMhuos%2FnhOOdltkin0IsFq0%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1407971707", oauth_version="1.0"'

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
          @appDirectSuccessResponse = requireFixture('nock/appdirect_subscription_notice_deactivate_success')((new Account)._id)

        it 'returns a failed success and the reason', (done)->
          @agent
            .get(@url)
            .set('authorization', @validOauth)
            .expect(200)
            .end (err, res)->
              expect(err).to.be.null
              xml = _str.lines(res.text).join(' ')
              expect(xml).to.include("<success>false</success>")
              expect(xml).to.include("<errorCode>ACCOUNT_NOT_FOUND</errorCode>")
              done()


    describe 'success', ->
      beforeEach (done)->
        @account = new Account(billingProvider: 'appdirect', billingEmail: 'thomas@cine.io', productPlans: {broadcast: ['startup']})
        @account.save done

      describe 'Deactivate', ->
        beforeEach ->
          @appDirectSuccessResponse = requireFixture('nock/appdirect_subscription_notice_deactivate_success')(@account._id)

        beforeEach (done)->
          getAppdirectUrl.call(this, done)

        it 'returns success', ->
          expect(@res.statusCode).to.equal(200)
          expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

        it 'sends the oauth headers to AppDirect', ->
          expect(@appDirectSuccessResponse.isDone()).to.be.true

        it "updates the account's subscription", (done)->
          Account.findOne billingEmail: 'thomas@cine.io', (err, account)->
            expect(err).to.be.null
            expect(account.deletedAt).to.be.instanceOf(Date)
            done()

        it 'returns success and the correct identifier', (done)->
          xml = _str.lines(@res.text).join(' ')
          expect(xml).to.include("<success>true</success>")
          id = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
          Account.findById id, (err, account)->
            expect(err).to.be.null
            expect(account.deletedAt).to.be.instanceOf(Date)
            done()

      describe 'Reactivate', ->

        beforeEach (done)->
          @account.deletedAt = new Date
          @account.save done

        beforeEach ->
          @appDirectSuccessResponse = requireFixture('nock/appdirect_subscription_notice_reactivate_success')(@account._id)

        beforeEach (done)->
          getAppdirectUrl.call(this, done)

        it 'returns success', ->
          expect(@res.statusCode).to.equal(200)
          expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

        it 'sends the oauth headers to AppDirect', ->
          expect(@appDirectSuccessResponse.isDone()).to.be.true

        it "updates the account's subscription", (done)->
          expect(@account.deletedAt).to.be.instanceOf(Date)
          Account.findOne billingEmail: 'thomas@cine.io', (err, account)=>
            expect(err).to.be.null
            expect(account._id.toString()).to.equal(@account._id.toString())
            expect(account.deletedAt).to.be.undefined
            done()

        it 'returns success and the correct identifier', (done)->
          xml = _str.lines(@res.text).join(' ')
          expect(xml).to.include("<success>true</success>")
          id = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
          Account.findById id, (err, account)->
            expect(err).to.be.null
            expect(account.deletedAt).to.be.undefined
            done()

      describe 'Closed', ->
        beforeEach ->
          @appDirectSuccessResponse = requireFixture('nock/appdirect_subscription_notice_closed_success')(@account._id)

        beforeEach (done)->
          getAppdirectUrl.call(this, done)

        it 'returns success', ->
          expect(@res.statusCode).to.equal(200)
          expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

        it 'sends the oauth headers to AppDirect', ->
          expect(@appDirectSuccessResponse.isDone()).to.be.true

        it "updates the account's subscription", (done)->
          Account.findOne billingEmail: 'thomas@cine.io', (err, account)->
            expect(err).to.be.null
            expect(account.deletedAt).to.be.instanceOf(Date)
            done()

        it 'returns success and the correct identifier', (done)->
          xml = _str.lines(@res.text).join(' ')
          expect(xml).to.include("<success>true</success>")
          id = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
          Account.findById id, (err, account)->
            expect(err).to.be.null
            expect(account.deletedAt).to.be.instanceOf(Date)
            done()

      describe 'Upcoming Invoice', ->
        beforeEach ->
          @appDirectSuccessResponse = requireFixture('nock/appdirect_subscription_notice_upcoming_invoice_success')(@account._id)

        beforeEach (done)->
          getAppdirectUrl.call(this, done)

        it 'returns success', ->
          expect(@res.statusCode).to.equal(200)
          expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

        it 'sends the oauth headers to AppDirect', ->
          expect(@appDirectSuccessResponse.isDone()).to.be.true

        it 'returns success and the correct identifier', ->
          xml = _str.lines(@res.text).join(' ')
          expect(xml).to.include("<success>false</success>")
          id = xml.match(/.*<errorCode>CONFIGURATION_ERROR<\/errorCode>.*/)[1]
