qs = require('qs')
_ = require('underscore')

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
    params.sessionUserId
    params.sessionUserId = session.user._id.toString() if session.user
    controller(params, callback)

module.exports = testApi
testApi.requresApiKey = (testApiResource)->
  it 'requires an api key', (done)->
    testApiResource {}, (err, response, options)->
      expect(err).to.equal('no api key')
      expect(response).to.be.null
      expect(options.status).to.equal(401)
      done()
