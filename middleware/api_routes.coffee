API_VERSION = 1
Project = Cine.model('project')
User = Cine.model('user')

class ResourceCaller
  constructor: (@resource, @req, @res)->
    @params = req.query
    @apiKey = @params.apiKey
    @sessionUserId = @req.user
  call: ->
    if @resource.project
      @_getProject =>
        @resource.call(this, @callback)
    else if @resource.user
      @_getUser =>
        @resource.call(this, @callback)
    else
      @resource.call(this, @callback)

  callback: (err, response, options={})=>
    return @_sendError(err, options) if err
    @res.send(response)

  _getProject: (callback)->
    return @_sendError('no api key', status: 401) unless @apiKey
    _getProjectCallback = (err, project)=>
      return @_sendError(err, status: 401) if err
      return @_sendError('invalid api key', status: 404) if !project
      @project = project
      callback()
    Project.findOne apiKey: @apiKey, _getProjectCallback

  _getUser: (callback)->
    return @_sendError('not logged in', status: 401) unless @sessionUserId
    _getUserCallback = (err, user)=>
      return @_sendError(err, status: 401) if err
      return @_sendError('user not found', status: 404) if !user
      @user = user
      callback()
    User.findById @sessionUserId, _getUserCallback

  _sendError: (err, options={})=>
    options.status ||= 400
    @res.send(options.status, err)

generateRoute = (resource)->
  return (req, res)->
    caller = new ResourceCaller resource, req, res
    caller.call()

createGetRoute = (app, resourceName, action, route)->
  route ||= resourceName
  resource = Cine.api("#{resourceName}/#{action}")
  app.get "/api/#{API_VERSION}/#{route}", generateRoute(resource)

createPostRoute = (app, resourceName, action, route)->
  route ||= resourceName
  resource = Cine.api("#{resourceName}/#{action}")
  app.post "/api/#{API_VERSION}/#{route}", generateRoute(resource)

apiRoutes = (app)->
  createGetRoute(app, 'health', 'index')

  createGetRoute(app, 'projects', 'show', 'me')
  createPostRoute(app, 'projects', 'create')

  createGetRoute(app, 'streams', 'index')
  createPostRoute(app, 'streams', 'create')

module.exports = apiRoutes
module.exports._generateRoute = generateRoute
