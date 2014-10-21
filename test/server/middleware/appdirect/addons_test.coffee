express = require('express')
Account = Cine.server_model('account')
supertest = require('supertest')
qs = require('qs')
_str = require('underscore.string')
createNewAccount = Cine.server_lib('create_new_account')

describe 'AppDirect/Addons', ->
  beforeEach ->
    @app = express()
    Cine.middleware('appdirect', @app)
    @agent = supertest.agent(@app)

  beforeEach (done)->
    createNewAccount name: 'some name', billingProvider: 'appdirect', (err, results)=>
      @results = results
      @account = results.account
      @project = results.project
      done(err)

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
    @url = "/appdirect/addons?#{qs.stringify(@appdirectParams)}"
    @validOauth = 'OAuth oauth_consumer_key="cineio-12056", oauth_nonce="1746785885757644257", oauth_signature="ZrJD%2BMpkEnoUwZ%2BBchRagwzL9F4%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1407971707", oauth_version="1.0"'


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


  describe 'order', ->

    beforeEach ->
      @appDirectSuccessResponse = requireFixture('nock/appdirect_addon_order')(@account._id)

    describe 'standard', ->
      beforeEach (done)->
        getAppdirectUrl.call(this, done)

      it 'returns success', ->
        expect(@res.statusCode).to.equal(200)
        expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

      it 'sends the oauth headers to AppDirect', ->
        expect(@appDirectSuccessResponse.isDone()).to.be.true

      it 'adds the addon to the account', (done)->
        expect(@account.plans).to.have.length(0)
        Account.findById @account._id, (err, account)->
          expect(err).to.be.null
          expect(account.plans).to.have.length(1)
          expect(account.plans[0]).to.equal('solo')
          done()

      it 'returns success and the correct identifier', ->
        xml = _str.lines(@res.text).join(' ')
        expect(xml).to.include("<success>true</success>")
        expect(xml).to.include("solo was added")
        id = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
        expect(id).to.equal(@account._id.toString())

    describe 'other', ->
      it 'unthrottles an account', (done)->
        @account.throttledAt = new Date
        @account.save (err, account)=>
          expect(err).to.be.null
          expect(account.throttledAt).to.be.instanceOf(Date)
          getAppdirectUrl.call this, (err)->
            expect(err).to.be.null
            Account.findById account._id, (err, accountFromDb)->
              expect(err).to.be.null
              expect(accountFromDb.throttledAt).to.be.undefined
              done()

  describe 'cancel', ->

    beforeEach (done)->
      @account.plans = [ 'solo', 'basic', 'solo']
      @account.save done

    beforeEach ->
      @appDirectSuccessResponse = requireFixture('nock/appdirect_addon_cancel')(@account._id)

    beforeEach (done)->
      getAppdirectUrl.call(this, done)

    it 'returns success', ->
      expect(@res.statusCode).to.equal(200)
      expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

    it 'sends the oauth headers to AppDirect', ->
      expect(@appDirectSuccessResponse.isDone()).to.be.true

    it 'removes the addon to the account', (done)->
      expect(@account.plans).to.have.length(3)
      Account.findById @account._id, (err, account)->
        expect(err).to.be.null
        expect(account.plans).to.have.length(2)
        expect(account.plans[0]).to.equal('basic')
        expect(account.plans[1]).to.equal('solo')
        done()

    it 'returns success and the correct identifier', ->
      xml = _str.lines(@res.text).join(' ')
      expect(xml).to.include("solo was removed")
      expect(xml).to.include("<success>true</success>")
      id = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
      expect(id).to.equal(@account._id.toString())

  describe 'bind', ->

    beforeEach ->
      @appDirectSuccessResponse = requireFixture('nock/appdirect_addon_bind')(@account._id)

    beforeEach (done)->
      getAppdirectUrl.call(this, done)

    it 'returns success', ->
      expect(@res.statusCode).to.equal(200)
      expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

    it 'sends the oauth headers to AppDirect', ->
      expect(@appDirectSuccessResponse.isDone()).to.be.true

    it 'returns the project secretKey', ->
      xml = _str.lines(@res.text).join(' ')
      expect(xml).to.include("<success>true</success>")
      id = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
      expect(id).to.equal(@account._id.toString())

    it 'returns the project publicKey', ->
      xml = _str.lines(@res.text).join(' ')
      expect(xml).to.include("<key>secretKey</key>")
      expect(xml).to.include("<value>#{@project.secretKey}</value>")
      expect(xml).to.include("<key>publicKey</key>")
      expect(xml).to.include("<value>#{@project.publicKey}</value>")

    it 'returns success and the correct identifier', ->
      xml = _str.lines(@res.text).join(' ')
      expect(xml).to.include("<success>true</success>")
      expect(xml).to.include("was bound")
      id = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
      expect(id).to.equal(@account._id.toString())

  describe 'unbind', ->
    beforeEach ->
      @appDirectSuccessResponse = requireFixture('nock/appdirect_addon_unbind')(@account._id)

    beforeEach (done)->
      getAppdirectUrl.call(this, done)

    it 'returns success', ->
      expect(@res.statusCode).to.equal(200)
      expect(@res.headers['content-type']).to.equal('text/xml; charset=utf-8')

    it 'sends the oauth headers to AppDirect', ->
      expect(@appDirectSuccessResponse.isDone()).to.be.true

    it 'returns success and the correct identifier', ->
      xml = _str.lines(@res.text).join(' ')
      expect(xml).to.include("<success>true</success>")
      expect(xml).to.include("was unbound")
      id = xml.match(/.*<accountIdentifier>(.+)<\/accountIdentifier>.*/)[1]
      expect(id).to.equal(@account._id.toString())
