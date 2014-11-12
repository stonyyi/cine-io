Project = Cine.server_model('project')
User = Cine.server_model('user')
Account = Cine.server_model('account')
_ = require('underscore')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
mailer = Cine.server_lib('mailer')
deleteAccount = Cine.server_lib('delete_account')
createNewAccount = Cine.server_lib('create_new_account')
AccountThrottler = Cine.server_lib('account_throttler')

nameFromHerokuId = (herokuId)->
  herokuId.split('@')[0]

nameFromEngineYardId = (engineyardId)->
  matches = engineyardId.match(/(\d+)-(.+)/)
  if matches then matches[2] else engineyard

# herokuId: 'app6848@kensa.heroku.com'
# plan: 'free'
# callback(err, user, project)
exports.newHerokuAccount = (herokuId, plan, callback)->
  accountAttributes =
    herokuId: herokuId
    name: nameFromHerokuId(herokuId)
    plan: plan
    billingProvider: 'heroku'
  projectAttributes =
    name: nameFromHerokuId(herokuId)
  userAttributes = {}
  createNewAccount accountAttributes, userAttributes, projectAttributes, (err, results)->
    return callback(err) if err
    mailer.admin.newUser(results.account, null, 'heroku')
    callback(null, results.account, results.project)

exports.newEngineYardAccount = (engineyardId, plan, callback)->
  accountAttributes =
    engineyardId: engineyardId
    name: nameFromEngineYardId(engineyardId)
    plan: plan
    billingProvider: 'engineyard'
  projectAttributes =
    name: nameFromEngineYardId(engineyardId)
  userAttributes = {}
  createNewAccount accountAttributes, userAttributes, projectAttributes, (err, results)->
    return callback(err) if err
    mailer.admin.newUser(results.account, null, 'engineyard')
    callback(null, results.account, results.project)

# callback(err, user)
# This finds a user by email
#
exports.findUser = (accountId, userEmail, req, callback)->
  User.findOne email: userEmail, (err, user)->
    return callback(err) if err

    if !user
      Account.findById accountId, (err, account)->
        return callback(err) if err
        user = new User
          email: userEmail
          name: account.name
          lastLoginIP: req.ip
          createdAtIP: req.ip
        user._accounts.push accountId
        user.save callback
    else
      hasAccount = (userAccountId)->
        userAccountId.toString() == accountId.toString()
      # return the user if the user already
      user._accounts.push accountId unless _.any user.accounts, hasAccount
      user.lastLoginIP = req.ip
      user.save callback

setPlanAndEnsureNotDeleted = (account, plan, callback)->
  account.deletedAt = undefined
  account.plans = [plan]
  AccountThrottler.unthrottle account, (err, account)->
    return callback(err) if err
    callback(null, account)

# callback(err, user)
exports.updatePlan = (accountId, plan, callback)->
  Account.findOne accountId, (err, account)->
    return callback(err) if err
    return callback('account not found') unless account
    setPlanAndEnsureNotDeleted(account, plan, callback)

# callback(err, user)
exports.deleteAccount = (accountId, callback)->
  Account.findById accountId, (err, account)->
    return callback(err) if err
    return callback('account not found') unless account
    deleteAccount(account, callback)
