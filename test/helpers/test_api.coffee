generateRoute = Cine.middleware('api_routes')._generateRoute
qs = require('qs')
_ = require('underscore')
convertParams = (params)->
  newParams = {}
  _.each params, (value, key)->
    # http://stackoverflow.com/questions/13850819/can-i-determine-if-a-string-is-a-mongodb-objectid
    if value.toString().match /^[0-9a-fA-F]{24}$/
      newParams[key] = value.toString()
    else
      newParams[key] = value
  qs.parse qs.stringify newParams
testApi = (resource)->
  callRoute = generateRoute(resource)
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
    req =
      query: convertParams(params)
    if callback == undefined
      callback = session
      session = {}
    req.user = session.user._id.toString() if session.user
    res =
      send: (responseOrStatus, response)->
        return callback(response, null, status: responseOrStatus) if response
        callback(null, responseOrStatus)
    callRoute(req, res)

module.exports = testApi
testApi.requresApiKey = (testApiResource)->
  it 'requires an api key', (done)->
    testApiResource {}, (err, response, options)->
      expect(err).to.equal('no api key')
      expect(response).to.be.null
      expect(options.status).to.equal(401)
      done()
