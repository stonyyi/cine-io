Project = Cine.server_model('project')
User = Cine.server_model('user')
PermissionManager = Cine.lib('permission_manager')

requiredMessage = (requires)->
  switch requires
    when 'key' then 'api key required'
    when 'secret' then 'api secret required'
    when 'either' then 'api key or api secret required'

cannotFindMessage = (requires)->
  switch requires
    when 'key' then 'invalid api key'
    when 'secret' then 'invalid api secret'
    when 'either' then 'invalid api key or api secret'

# options are
# requires: key|secret|either
#   that the call needs either a key, secret, or either
# userOverride: true|false
#   having a logged in user and apiKey can count as an api secret

doFind = (queryParams, options, callback)->
  Project.findOne queryParams, (err, project)->
    return callback(err, null, status: 401) if err
    return callback(cannotFindMessage(options.requires), null, status: 404) if !project
    # return secure: true if we queried based on an apiSecret
    callback(null, project, secure: queryParams.apiSecret?)

userOverrideVersion = (params, options, callback)->
  doFind {apiKey: params.apiKey}, options, (err, project, returnOptions)->
    return callback(err, project, returnOptions) if err || !project
    User.findById params.sessionUserId, (err, user)->
      return callback(err, null, status: 400) if err
      p = new PermissionManager(user.permissions)
      return callback('not permitted', null, status: 401) unless p.check('edit', project)
      callback(null, project, secure: true)

module.exports = (params, options, callback)->
  callbackAllowsUserOverride = options.userOverride && !params.apiSecret && options.requires != 'key'
  return userOverrideVersion(params, options, callback) if callbackAllowsUserOverride && params.sessionUserId && params.apiKey

  queryParams = {}
  switch options.requires
    when 'key'
      return callback(requiredMessage(options.requires), null, status: 401) unless params.apiKey
      queryParams = apiKey: params.apiKey
    when 'secret'
      return callback(requiredMessage(options.requires), null, status: 401) unless params.apiSecret
      queryParams = apiSecret: params.apiSecret
    when 'either'
      return callback(requiredMessage(options.requires), null, status: 401) unless params.apiKey || params.apiSecret
      queryParams.apiKey = params.apiKey if params.apiKey
      queryParams.apiSecret = params.apiSecret if params.apiSecret
  doFind queryParams, options, callback
