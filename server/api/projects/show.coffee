getProject = Cine.server_lib('get_project')

module.exports = (params, callback)->
  getProject params, (err, project, status)->
    return callback(err, project, status) if err
    response =
      id: project._id.toString()
      name: project.name
    callback(null, response)
