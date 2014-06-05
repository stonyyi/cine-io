Project = Cine.server_model('project')
User = Cine.server_model('user')
PermissionManager = Cine.lib('permission_manager')

requiredMessage = (requires)->
  switch requires
    when 'key' then 'public key required'
    when 'secret' then 'secret key required'
    when 'either' then 'public key or secret key required'

cannotFindMessage = (requires)->
  switch requires
    when 'key' then 'invalid public key'
    when 'secret' then 'invalid secret key'
    when 'either' then 'invalid public key or secret key'

# options are
# requires: key|secret|either
#   that the call needs either a key, secret, or either
# userOverride: true|false
#   having a logged in user and publicKey can count as an secretKey

doFind = (queryParams, options, callback)->
  Project.findOne queryParams, (err, project)->
    return callback(err, null, status: 401) if err
    return callback(cannotFindMessage(options.requires), null, status: 401) if !project
    # return secure: true if we queried based on an secretKey
    callback(null, project, secure: queryParams.secretKey?)

userOverrideVersion = (params, options, callback)->
  doFind {publicKey: params.publicKey}, options, (err, project, returnOptions)->
    return callback(err, project, returnOptions) if err || !project
    User.findById params.sessionUserId, (err, user)->
      return callback(err, null, status: 400) if err
      p = new PermissionManager(user.permissions)
      return callback('not permitted', null, status: 401) unless p.check('edit', project)
      callback(null, project, secure: true)

module.exports = (params, options, callback)->
  callbackAllowsUserOverride = options.userOverride && !params.secretKey && options.requires != 'key'
  return userOverrideVersion(params, options, callback) if callbackAllowsUserOverride && params.sessionUserId && params.publicKey

  queryParams = {deletedAt: {$exists: false}}
  switch options.requires
    when 'key'
      return callback(requiredMessage(options.requires), null, status: 401) unless params.publicKey
      queryParams = publicKey: params.publicKey
    when 'secret'
      return callback(requiredMessage(options.requires), null, status: 401) unless params.secretKey
      queryParams = secretKey: params.secretKey
    when 'either'
      return callback(requiredMessage(options.requires), null, status: 401) unless params.publicKey || params.secretKey
      queryParams.publicKey = params.publicKey if params.publicKey
      queryParams.secretKey = params.secretKey if params.secretKey
  doFind queryParams, options, callback
