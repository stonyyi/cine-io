Project = Cine.model('project')

module.exports = (callback)->
  project = new Project
    name: @params.name
  project.save (err, project)=>
    return callback(err, null, status: 400) if err
    @user.permissions.push objectId: project._id, objectName: 'Project'
    @user.save (err, user)->
      return callback(err, null, status: 400) if err
      callback(null, project.toJSON())

module.exports.user = true
