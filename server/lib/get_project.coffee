Project = Cine.server_model('project')

module.exports = (params, callback)->
  apiKey = params.apiKey
  return callback('no api key', null, status: 401) unless apiKey
  Project.findOne apiKey: apiKey, (err, project)->
    return callback(err, null, status: 401) if err
    return callback('invalid api key', null, status: 404) if !project
    callback(null, project)
