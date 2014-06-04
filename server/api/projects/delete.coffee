getProject = Cine.server_lib('get_project')
ProjectShow = Cine.api('projects/show')

module.exports = (params, callback)->
  getProject params, requires: 'secret', userOverride: true, (err, project, status)->
    return callback(err, project, status) if err
    # TODO: TJS delete all associated streams
    project.deletedAt = new Date
    project.save (err, project)->
      return callback(err, null, status: 400) if err
      ProjectShow.toJSON(project, callback)
