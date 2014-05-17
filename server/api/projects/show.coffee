getProject = Cine.server_lib('get_project')

toJSON = (project, callback)->
  projectJSON =
    id: project._id.toString()
    apiKey: project.apiKey
    name: project.name

  callback(null, projectJSON)

Show = (params, callback)->
  getProject params, (err, project, status)->
    return callback(err, project, status) if err
    response =
      id: project._id.toString()
      name: project.name
    toJSON(project, callback)

module.exports = Show
module.exports.toJSON = toJSON
