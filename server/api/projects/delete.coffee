getProject = Cine.server_lib('get_project')
ProjectShow = Cine.api('projects/show')
EdgecastStream = Cine.server_model('edgecast_stream')
TurnUser = Cine.server_model('turn_user')

module.exports = (params, callback)->
  getProject params, requires: 'secret', userOverride: true, (err, project, options)->
    return callback(err, project, options) if err
    project.deletedAt = new Date
    project.save (err, project)->
      return callback(err, null, status: 400) if err
      query = _project: project._id
      update =
        $set: {deletedAt: new Date}
      options = multi: true
      TurnUser.remove _project: project._id, (err)->
        return callback(err, null, status: 400) if err

        EdgecastStream.update query, update, options, (err)->
          return callback(err, null, status: 400) if err
          ProjectShow.toJSON(project, callback)
