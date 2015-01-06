_ = require('underscore')
methods = ['get', 'post', 'put', 'delete']

routes = module.exports
_.each methods, (method)->
  routes[method] = {}

routes.get['/'] = Cine.api "root"

newApiRoute = (controllerAction, options, method)->
  parts = controllerAction.split('#')
  controller = parts[0]
  action = parts[1]
  url = options.url
  route = "/#{url}"
  resource = Cine.api "#{controller}/#{action}"
  routes[method][route] = resource

get = (controllerAction, options)-> newApiRoute(controllerAction, options, 'get')
post = (controllerAction, options)-> newApiRoute(controllerAction, options, 'post')
put = (controllerAction, options)-> newApiRoute(controllerAction, options, 'put')
# delete is a reserved keyword
destroy = (controllerAction, options)-> newApiRoute(controllerAction, options, 'delete')

get 'server#nearest', url: 'nearest-server'

get 'health#index', url: 'health'

get 'stats#show', url: 'stats'

get     'projects#index', url: 'projects'
get     'projects#show',   url: 'project'
post    'projects#create', url: 'project'
put     'projects#update', url: 'project'
destroy 'projects#delete', url: 'project'

get     'streams#index', url: 'streams'
get     'streams#show',   url: 'stream'
post    'streams#create', url: 'stream'
put     'streams#update', url: 'stream'
destroy 'streams#delete', url: 'stream'

get 'stream_recordings#index', url: 'stream/recordings'
destroy 'stream_recordings#delete', url: 'stream/recording'

get 'static_documents#show', url: 'static-document'

get 'usage/accounts#show', url: 'usage/account'
get 'usage/projects#show', url: 'usage/project'
get 'usage/streams#show', url: 'usage/stream'

get  'users#show', url: 'user'
post 'users#update_account', url: 'update-account'
put  'users#update', url: 'user'

get     'accounts#index', url: 'accounts'
put     'accounts#update', url: 'account'
destroy 'accounts#delete', url: 'account'

get  'password_change_requests#show', url: 'password-change-request'
post 'password_change_requests#create', url: 'password-change-request'
