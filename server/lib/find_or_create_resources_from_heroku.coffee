Project = Cine.server_model('project')
User = Cine.server_model('user')
_ = require('underscore')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
mailer = Cine.server_lib('mailer')
deleteUser = Cine.server_lib('delete_user')
createNewAccount = Cine.server_lib('create_new_account')

nameFromEmail = (herokuId)->
  herokuId.split('@')[0]

# herokuId: 'app6848@kensa.heroku.com'
# plan: 'free'
# callback(err, user, project)
exports.newAccount = (herokuId, plan, callback)->
  accountAttributes =
    herokuId: herokuId
    plan: plan
  projectAttributes =
    name: nameFromEmail(herokuId)
  # TODO: DEPRECATED
  userAttributes =
    name: nameFromEmail(herokuId)
  createNewAccount accountAttributes, userAttributes, projectAttributes, (err, results)->
    return callback(err) if err
    mailer.admin.newUser(results.user, 'heroku')
    callback(null, results.user, results.project)

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
