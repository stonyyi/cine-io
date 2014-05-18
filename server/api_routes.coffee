module.exports = (app)->
  newApiRoute = (controller, action, options, method)->
    url = options?.url || controller
    route = "/api/#{url}"
    resource = Cine.api "#{controller}/#{action}"
    app[method](route, resource)

  get = (controller, action, options)-> newApiRoute(controller, action, options, 'get')
  post = (controller, action, options)-> newApiRoute(controller, action, options, 'post')
  put = (controller, action, options)-> newApiRoute(controller, action, options, 'put')

  get 'health', 'index'

  get 'projects', 'index'
  get 'projects', 'show', url: 'project'
  post 'projects', 'create', url: 'project'

  get 'streams', 'index'
  get 'streams', 'show', url: 'stream'
  post 'streams', 'create'
