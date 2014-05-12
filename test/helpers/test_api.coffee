generateRoute = Cine.middleware('api_routes')._generateRoute
module.exports = (resource)->
  callRoute = generateRoute(resource)
  return (params, callback)->
    req =
      query: params
    res =
      send: (responseOrStatus, response)->
        return callback(responseOrStatus, response) if response
        callback(null, responseOrStatus)
    callRoute(req, res)
