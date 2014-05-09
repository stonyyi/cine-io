API_VERSION = 1
sendError = (err, options, res)->
  options.status ||= 400
  res.send(options.status, err)

makeApiCall = (resource, action)->
  resource = SS.api("#{resource}/#{action}")
  return (req, res)->
    resource req.query, (err, response, options={})->
      return sendError(err, options, res) if err
      res.send(response)

createApiRoute = (app, resource, action)->
  app.get "/api/#{API_VERSION}/#{resource}", makeApiCall(resource, action)

module.exports = (app)->
  createApiRoute(app, 'streams', 'index')
  createApiRoute(app, 'health', 'index')
