qs = require('qs')
_ = require('underscore')
User = Cine.server_model('user')

stringifyParams = (params)->
  newParams = {}
  _.each params, (value, key)->
    # http://stackoverflow.com/questions/13850819/can-i-determine-if-a-string-is-a-mongodb-objectid
    if value.toString().match /^[0-9a-fA-F]{24}$/
      newParams[key] = value.toString()
    else
      newParams[key] = value
  qs.parse qs.stringify newParams

testApi = (controller)->
  # params, session (optional), callback
  return ->
    params = {}
    session = {}
    if arguments.length == 1
      callback = arguments[0]
    if arguments.length > 1
      params = arguments[0]
    if arguments.length > 2
      session = arguments[1]
    callback = arguments[arguments.length - 1]
    params = stringifyParams(params)
    if callback == undefined
      callback = session
      session = {}
    params.sessionUserId = session.user._id.toString() if session.user
    controller(params, callback)

module.exports = testApi

requiredMessage = (requires)->
  switch requires
    when 'key' then 'public key required'
    when 'secret' then 'secret key required'
    when 'either' then 'public key or secret key required'

testApi.requresApiKey = (testApiResource, requires)->
  it "requires a #{requires} key", (done)->
    testApiResource {}, (err, response, options)->
      expect(err).to.equal(requiredMessage(requires))
      expect(response).to.be.null
      expect(options.status).to.equal(401)
      done()

testApi.requresLoggedIn = (testApiResource)->
  it 'requires a logged in user', (done)->
    testApiResource {}, (err, response, options)->
      expect(err).to.equal('not logged in or masterKey not supplied')
      expect(response).to.be.null
      expect(options.status).to.equal(401)
      done()

testApi.requiresMasterKey = (testApiResource)->
  it 'requires an account masterKey', (done)->
    testApiResource {}, (err, response, options)->
      expect(err).to.equal('masterKey not supplied')
      expect(response).to.be.null
      expect(options.status).to.equal(401)
      done()

testApi.requiresSiteAdmin = (testApiResource)->
  describe 'requires a site admin', ->
    beforeEach (done)->
      @requiresSiteAdminUser = new User
      @requiresSiteAdminUser.save done

    it 'is unauthorized when not logged in', (done)->
      testApiResource {}, (err, response, options)->
        expect(err).to.equal('Unauthorized')
        expect(response).to.be.null
        expect(options.status).to.equal(401)
        done()

    it 'is unauthorized when not a site admin', (done)->
      testApiResource {}, user: @requiresSiteAdminUser, (err, response, options)->
        expect(err).to.equal('Unauthorized')
        expect(response).to.be.null
        expect(options.status).to.equal(401)
        done()
