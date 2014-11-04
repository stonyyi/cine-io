app = Cine.require('app').app
User = Cine.server_model('user')
Account = Cine.server_model('account')
supertest = require('supertest')
qs = require('qs')
_str = require('underscore.string')

describe 'AppDirect/Login', ->
  beforeEach ->
    # I'm testing the actual app so req.currentUser works
    # and passport/sessions need to be initialized yadda yadda.
    @agent = supertest.agent(app)

  app.get '/whoami', (req, res)->
    res.send(req.currentUser)

  describe 'appdirect/login', ->
    it 'requires an openid param', (done)->
      @agent
        .get("/appdirect/login")
        .expect(401)
        .end done

    beforeEach ->
      @initialRequest = requireFixture('nock/appdirect_openid/initial_request')()
      @openidOpRequest = requireFixture('nock/appdirect_openid/openid_op_request')()

    it 'takes and openid param and sends back a callback url', (done)->
      params =
        openid: "https://www.appdirect.com/openid/id/a959d462-a6b0-41e3-b0eb-c73c1d199fd3"
        accountIdentifier: "53ee4a5932337906002096d9"
      url = "/appdirect/login?#{qs.stringify(params)}"
      @agent
        .get("/appdirect/login?#{qs.stringify(params)}")
        .expect(302)
        .end (err, res)=>
          expect(err).to.be.null
          expect(@initialRequest.isDone()).to.be.true
          expectedLocation = 'https://www.appdirect.com/openid/op?openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&openid.sreg.optional=nickname%2Cemail%2Cfullname%2Cdob%2Cgender%2Cpostcode%2Ccountry%2Clanguage%2Ctimezone&openid.ns.ax=http%3A%2F%2Fopenid.net%2Fsrv%2Fax%2F1.0&openid.ax.mode=fetch_request&openid.ax.type.fullname=http%3A%2F%2Faxschema.org%2FnamePerson&openid.ax.type.firstname=http%3A%2F%2Faxschema.org%2FnamePerson%2Ffirst&openid.ax.type.lastname=http%3A%2F%2Faxschema.org%2FnamePerson%2Flast&openid.ax.type.email=http%3A%2F%2Faxschema.org%2Fcontact%2Femail&openid.ax.required=fullname%2Cfirstname%2Clastname%2Cemail&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.return_to=http%3A%2F%2Flocaltest.me%3A8181%2Fappdirect%2Flogin%2Fcallback&openid.realm=http%3A%2F%2Flocaltest.me%3A8181%2F'
          textUrl = 'https://www.appdirect.com/openid/op?openid.mode=checkid_setup&openid.ns=http%253A%252F%252Fspecs.openid.net%252Fauth%252F2.0&openid.ns.sreg=http%253A%252F%252Fopenid.net%252Fextensions%252Fsreg%252F1.1&openid.sreg.optional=nickname%252Cemail%252Cfullname%252Cdob%252Cgender%252Cpostcode%252Ccountry%252Clanguage%252Ctimezone&openid.ns.ax=http%253A%252F%252Fopenid.net%252Fsrv%252Fax%252F1.0&openid.ax.mode=fetch_request&openid.ax.type.fullname=http%253A%252F%252Faxschema.org%252FnamePerson&openid.ax.type.firstname=http%253A%252F%252Faxschema.org%252FnamePerson%252Ffirst&openid.ax.type.lastname=http%253A%252F%252Faxschema.org%252FnamePerson%252Flast&openid.ax.type.email=http%253A%252F%252Faxschema.org%252Fcontact%252Femail&openid.ax.required=fullname%252Cfirstname%252Clastname%252Cemail&openid.identity=http%253A%252F%252Fspecs.openid.net%252Fauth%252F2.0%252Fidentifier_select&openid.claimed_id=http%253A%252F%252Fspecs.openid.net%252Fauth%252F2.0%252Fidentifier_select&openid.assoc_handle=381655eecf29e80&openid.return_to=http%253A%252F%252Flocaltest.me%253A8181%252Fappdirect%252Flogin%252Fcallback&openid.realm=http%253A%252F%252Flocaltest.me%253A8181%252F'
          expect(res.headers.location).to.equal(expectedLocation)
          done()

  describe 'appdirect/login/callback', ->

    beforeEach ->
      @openIdRequest = requireFixture('nock/appdirect_openid/openid_id_request')()
      @openIdResponse = requireFixture('nock/appdirect_openid/openid_op_response')()

    beforeEach (done)->
      @user = new User
        appdirectUUID: 'a959d462-a6b0-41e3-b0eb-c73c1d199fd3'
        lastLoginIP: '888.777.666.555'
      @user.save done

    beforeEach (done)->
      url = "/appdirect/login/callback?openid.ns=http://specs.openid.net/auth/2.0&openid.op_endpoint=https://www.appdirect.com/openid/op&openid.claimed_id=https://www.appdirect.com/openid/id/a959d462-a6b0-41e3-b0eb-c73c1d199fd3&openid.response_nonce=2014-11-04T20:22:55Z150&openid.mode=id_res&openid.identity=https://www.appdirect.com/openid/id/a959d462-a6b0-41e3-b0eb-c73c1d199fd3&openid.return_to=http://127.0.0.1/appdirect/login/callback&openid.assoc_handle=dec96b4767fb475f&openid.signed=op_endpoint,claimed_id,identity,return_to,response_nonce,assoc_handle,ns.sreg,ns.ext2,sreg.email,sreg.fullname,sreg.country,sreg.language,ext2.mode,ext2.type.fullname,ext2.value.fullname,ext2.type.firstname,ext2.value.firstname,ext2.type.lastname,ext2.value.lastname,ext2.type.email,ext2.value.email&openid.sig=EwuKVhJMWiN6hYdkKhABn2DYrjspXGSD735Dm%2BGDLGI%3D&openid.ns.sreg=http://openid.net/sreg/1.0&openid.sreg.email=thomas@cine.io&openid.sreg.fullname=Thomas+Shafer&openid.sreg.country=US&openid.sreg.language=en&openid.ns.ext2=http://openid.net/srv/ax/1.0&openid.ext2.mode=fetch_response&openid.ext2.type.fullname=http://axschema.org/namePerson&openid.ext2.value.fullname=Thomas+Shafer&openid.ext2.type.firstname=http://axschema.org/namePerson/first&openid.ext2.value.firstname=Thomas&openid.ext2.type.lastname=http://axschema.org/namePerson/last&openid.ext2.value.lastname=Shafer&openid.ext2.type.email=http://axschema.org/contact/email&openid.ext2.value.email=thomas@cine.io"
      @agent
        .get(url)
        .end (err, @res)=>
          process.nextTick ->
            done(err)

    it 'calls to AppDirect', ->
      expect(@openIdRequest.isDone()).to.be.true
      expect(@openIdResponse.isDone()).to.be.true

    it 'logs the user in', (done)->
      @agent.get('/whoami').expect(200).end (err, res)=>
        expect(err).to.be.null
        currentUser = JSON.parse(res.text)
        expect(currentUser.id.toString()).to.equal(@user._id.toString())
        done()

    it 'updates lastLoginIP for the user', (done)->
      User.findById @user._id, (err, user)->
        expect(err).to.be.null
        expect(user.lastLoginIP).to.equal('127.0.0.1')
        done()
