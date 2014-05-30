getProject = Cine.server_lib('get_project')

toJSON = (project, callback)->
  projectJSON =
    id: project._id.toString()
    publicKey: project.publicKey
    secretKey: project.secretKey
    name: project.name
    plan: project.plan
    streamsCount: project.streamsCount
    updatedAt: project.updatedAt

  callback(null, projectJSON)

Show = (params, callback)->
  getProject params, requires: 'secret', userOverride: true, (err, project, status)->
    return callback(err, project, status) if err
    toJSON(project, callback)

module.exports = Show
module.exports.toJSON = toJSON
