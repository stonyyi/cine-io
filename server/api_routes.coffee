module.exports = (app)->
  newApiRoute = (controller, action, url, method)->
    url = controller if url == undefined
    route = "/api/#{url}"
    resource = Cine.api "#{controller}/#{action}"
    app[method](route, resource)

  get = (controller, action, url)-> newApiRoute(controller, action, url, 'get')
  post = (controller, action, url)-> newApiRoute(controller, action, url, 'post')
  put = (controller, action, url)-> newApiRoute(controller, action, url, 'put')

  get 'health', 'index'

  get 'projects', 'index'
  get 'projects', 'show', 'me'
  post 'projects', 'create'

  get 'streams', 'index'
  get 'streams', 'show', 'stream'
  post 'streams', 'create'
