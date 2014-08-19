Project = Cine.server_model('project')
getAccount = Cine.server_lib('get_account')
ProjectShow = Cine.api('projects/show')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')

Create = (params, callback)->
  getAccount params, (err, account, status)->
    return callback(err, account, status) if err
    addProjectToAccountAndSave(account, params, callback)

addProjectToAccountAndSave = (account, params, callback)->
  project = new Project
    name: params.name
    plan: params.plan
    _account: account._id
  project.save (err, project)->
    return callback(err, null, status: 400) if err
    # we can create a stream here automatically if we pass createStream: true
    return ProjectShow.toJSON project, callback unless params.createStream in ['true', true]
    addNextStreamToProject project, name: params.streamName, (err, stream)->
      return callback(err, null, status: 400) if err
      # we create the stream but just return the project
      ProjectShow.toJSON project, callback

module.exports = Create
