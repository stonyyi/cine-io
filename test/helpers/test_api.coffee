generateRoute = Cine.middleware('api_routes')._generateRoute
testApi = (resource)->
  callRoute = generateRoute(resource)
  return (params, callback)->
    req =
      query: params
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
