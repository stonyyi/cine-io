Project = Cine.server_model('project')

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
# requires: ['key', 'secret', or 'either']
module.exports = (params, options, callback)->
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
  Project.findOne queryParams, (err, project)->
    return callback(err, null, status: 401) if err
    return callback(cannotFindMessage(options.requires), null, status: 404) if !project
    # return secure: true if we queried based on an apiSecret
    callback(null, project, secure: queryParams.apiSecret?)
