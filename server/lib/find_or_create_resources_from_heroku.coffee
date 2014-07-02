Project = Cine.server_model('project')
User = Cine.server_model('user')
_ = require('underscore')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
mailer = Cine.server_lib('mailer')
deleteUser = Cine.server_lib('delete_user')

nameFromEmail = (herokuId)->
  herokuId.split('@')[0]

# they're creating or updating a plan, it cannot be deleted then
getOrAddProjectToExistingUser = (user, herokuId, plan, callback)->
  user.projects (err, projects)->
    return callback(null, user, projects[0]) if projects.length > 0
    project = new Project(name: nameFromEmail(herokuId))
    project.save (err, project)->
      return callback(err) if err
      user.permissions.push objectId: project._id, objectName: 'Project'
      setPlanAndEnsureNotDeleted user, plan, (err, user)->
        callback(null, user, project)

# herokuId: 'app6848@kensa.heroku.com'
# plan: 'free'
# callback(err, user, project)
exports.createProjectAndUser = (herokuId, plan, callback)->
  User.findOne herokuId: herokuId, (err, user)->
    callback(err, project) if err
    return getOrAddProjectToExistingUser(user, herokuId, plan, callback) if user

    project = new Project(name: nameFromEmail(herokuId))
    project.save (err, project)->
      return callback(err) if err
      user = new User(name: nameFromEmail(herokuId), plan: plan, herokuId: herokuId)
      user.permissions.push objectId: project._id, objectName: 'Project'
      user.save (err, user)->
        return callback(err) if err
        addNextStreamToProject project, (err, stream)->
          # we still want to allow the project to be created even if there is no stream
          mailer.admin.newUser(user, 'heroku')
          return callback(null, user, project) if err == 'Next stream not available, please try again later'
          callback(err, user, project)

# callback(err, user)
exports.findUser = (userId, callback)->
  User.findById userId, callback

setPlanAndEnsureNotDeleted = (user, plan, callback)->
  user.deletedAt = undefined
  user.plan = plan
  user.save callback

# callback(err, user)
exports.updatePlan = (userId, plan, callback)->
  exports.findUser userId, (err, user)->
    return callback(err) if err
    return callback('user not found') unless user
    setPlanAndEnsureNotDeleted(user, plan, callback)

# callback(err, user)
exports.deleteUser = (userId, callback)->
  User.findById userId, (err, user)->
    return callback(err) if err
    return callback('user not found') unless user
    deleteUser(user, callback)
