getProject = Cine.server_lib('get_project')
ProjectShow = Cine.api('projects/show')

module.exports = (params, callback)->
  getProject params, requires: 'secret', userOverride: true, (err, project, options)->
    return callback(err, project, options) if err
    project.name = params.name
    project.save (err, project)->
      return callback(err, null, status: 400) if err
      ProjectShow.toJSON(project, callback)
