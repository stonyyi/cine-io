API_VERSION = 1
Organization = Cine.model('organization')

sendError = (err, res, options={})->
  options.status ||= 400
  res.send(options.status, err)

callResource = (resource, params, res, organization)->
  responder = (err, response, options={})->
    return sendError(err, res, options) if err
    res.send(response)
  switch resource.length
    when 1
      resource responder
    when 2
      resource params, responder
    when 3
      resource organization, params, responder

notAuthenticatedRoute = (resource)->
  return (req, res)->
    params = req.query
    callResource(resource, params, res)

authenticatedRoute = (resource)->
  return (req, res)->
    params = req.query
    apiKey = params.apiKey
    return sendError('no api key', null, status: 401) unless apiKey
    responder = (err, organization)->
      return sendError(err || 'invalid api key', res, status: 401) if err || !organization
      callResource(resource, params, res, organization)
    Organization.findOne apiKey: apiKey, responder

generateRoute = (resource)->
  return notAuthenticatedRoute(resource) if resource.length <= 2
  return authenticatedRoute(resource)

createApiRoute = (app, resourceName, action, route)->
  route ||= resourceName
  resource = Cine.api("#{resourceName}/#{action}")
  app.get "/api/#{API_VERSION}/#{route}", generateRoute(resource)

apiRoutes = (app)->
  createApiRoute(app, 'streams', 'index')
  createApiRoute(app, 'health', 'index')
  createApiRoute(app, 'organizations', 'show', 'me')

module.exports = apiRoutes
module.exports._generateRoute = generateRoute
