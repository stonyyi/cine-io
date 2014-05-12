API_VERSION = 1
Organization = Cine.model('organization')

class ResourceCaller
  constructor: (@resource, @req, @res)->
    @params = req.query
    @apiKey = @params.apiKey
  call: ->
    if @resource.organization
      @_getOrganization =>
        @resource.call(this, @callback)
    else
      @resource.call(this, @callback)

  callback: (err, response, options={})=>
    return @_sendError(err, options) if err
    @res.send(response)

  _getOrganization: (callback)->
    return @_sendError('no api key', status: 401) unless @apiKey
    _getOrganizationCallback = (err, organization)=>
      return @_sendError(err || 'invalid api key', status: 401) if err || !organization
      @organization = organization
      callback()
    Organization.findOne apiKey: @apiKey, _getOrganizationCallback
  _sendError: (err, options={})=>
    options.status ||= 400
    @res.send(options.status, err)


generateRoute = (resource)->
  return (req, res)->
    caller = new ResourceCaller resource, req, res
    caller.call()

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
