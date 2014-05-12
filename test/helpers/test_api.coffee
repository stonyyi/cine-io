generateRoute = Cine.middleware('api_routes')._generateRoute
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
      query: params
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
