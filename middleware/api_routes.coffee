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

notAuthenticatedRoute = (resource, action)->
  return (req, res)->
    params = req.query
    callResource(resource, params, res)

authenticatedRoute = (resource, action)->
  return (req, res)->
    params = req.query
    responder = (err, organization)->
      return sendError(err || 'invalid api key', res, status: 401) if err || !organization
      callResource(resource, params, res, organization)
    Organization.findOne apiKey: params.apikey, responder

makeApiCall = (resourceName, action)->
  resource = Cine.api("#{resourceName}/#{action}")
  return notAuthenticatedRoute(resource, action) if resource.length <= 2
  return authenticatedRoute(resource)

createApiRoute = (app, resource, action, route)->
  route ||= resource
  app.get "/api/#{API_VERSION}/#{route}", makeApiCall(resource, action)

module.exports = (app)->
  createApiRoute(app, 'streams', 'index')
  createApiRoute(app, 'health', 'index')
  createApiRoute(app, 'organizations', 'show', 'me')
