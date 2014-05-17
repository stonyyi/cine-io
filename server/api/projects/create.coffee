Project = Cine.server_model('project')
getUser = Cine.server_lib('get_user')
Show = Cine.api('projects/show')

module.exports = (params, callback)->
  getUser params, (err, user, status)->
    return callback(err, user, status) if err
    project = new Project
      name: params.name
    project.save (err, project)->
      return callback(err, null, status: 400) if err
      user.permissions.push objectId: project._id, objectName: 'Project'
      user.save (err, user)->
        return callback(err, null, status: 400) if err
        Show.toJSON project, callback
