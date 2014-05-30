Project = Cine.server_model('project')
getUser = Cine.server_lib('get_user')
ProjectShow = Cine.api('projects/show')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')

module.exports = (params, callback)->
  getUser params, (err, user, status)->
    return callback(err, user, status) if err
    project = new Project
      name: params.name
      plan: params.plan
    project.save (err, project)->
      return callback(err, null, status: 400) if err
      user.permissions.push objectId: project._id, objectName: 'Project'
      user.save (err, user)->
        return callback(err, null, status: 400) if err
        # we can create a stream here automatically if we pass createStream: true
        return ProjectShow.toJSON project, callback unless params.createStream in ['true', true]
        addNextStreamToProject project, (err, stream)->
          return callback(err, null, status: 400) if err
          # we create the stream but just return the project
          ProjectShow.toJSON project, callback
