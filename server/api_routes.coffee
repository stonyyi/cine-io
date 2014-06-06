module.exports = (app)->
  app.get '/api/', Cine.api "root"

  newApiRoute = (controller, action, options, method)->
    url = options?.url || controller
    route = "/api/#{url}"
    resource = Cine.api "#{controller}/#{action}"
    app[method](route, resource)

  get = (controller, action, options)-> newApiRoute(controller, action, options, 'get')
  post = (controller, action, options)-> newApiRoute(controller, action, options, 'post')
  put = (controller, action, options)-> newApiRoute(controller, action, options, 'put')
  # delete is a reserved keyword
  destroy = (controller, action, options)-> newApiRoute(controller, action, options, 'delete')

  get 'health', 'index'

  get 'projects', 'index'
  get 'projects', 'show', url: 'project'
  post 'projects', 'create', url: 'project'
  destroy 'projects', 'delete', url: 'project'

  get 'streams', 'index'
  get 'streams', 'show', url: 'stream'
  post 'streams', 'create', url: 'stream'
  destroy 'streams', 'delete', url: 'stream'

  get 'static-document', 'show', url: 'static-document'

  post "users", "update_account", url: 'update-account'
  put 'users', 'update'
