Project = Cine.server_model('project')
User = Cine.server_model('user')
_ = require('underscore')

nameFromEmail = (herokuId)->
  herokuId.split('@')[0]
# they're creating or updating a plan, it cannot be deleted then
setPlanAndEnsureNotDeleted = (project, plan, callback)->
  project.deletedAt = undefined
  project.plan = plan
  project.save callback

# herokuId: 'app6848@kensa.heroku.com'
# plan: 'free'
# callback(err, project)
exports.createProject = (herokuId, plan, callback)->
  Project.findOne herokuId: herokuId, (err, project)->
    callback(err, project) if err
    return setPlanAndEnsureNotDeleted(project, plan, callback) if project

    project = new Project(name: nameFromEmail(herokuId), herokuId: herokuId, plan: plan)
    project.save callback

# callback(err, project)
exports.findProject = (projectId, callback)->
  Project.findById projectId, callback

# callback(err, project)
exports.updatePlan = (projectId, plan, callback)->
  exports.findProject projectId, (err, project)->
    return callback(err) if err
    return callback('project not found') unless project
    setPlanAndEnsureNotDeleted(project, plan, callback)

# callback(err, project)
exports.deleteProject = (projectId, callback)->
  Project.findById projectId, (err, project)->
    return callback(err) if err
    return callback('project not found') unless project
    project.deletedAt = new Date
    project.save callback

# callback(err, user)
ensureUserOwnsProject = (user, project, callback)->
  permission = _.find user.permissions, (permission)->
    project._id.equals(permission.obejctId) && permission.objectName == 'Project'
  return callback(null, user) if permission
  user.permissions.push objectId: project._id, objectName: "Project"
  user.save callback

# callback(err, user)
exports.getProjectUser = (project, email, callback)->
  console.log('finding user', email)
  User.findOne email: email, (err, user)->
    return callback err if err
    return ensureUserOwnsProject(user, project, callback) if user
    user = new User email: email, name: nameFromEmail(email)
    user.permissions.push objectId: project._id, objectName: "Project"
    user.save callback
