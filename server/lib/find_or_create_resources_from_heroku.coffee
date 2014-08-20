Project = Cine.server_model('project')
User = Cine.server_model('user')
Account = Cine.server_model('account')
_ = require('underscore')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
mailer = Cine.server_lib('mailer')
deleteAccount = Cine.server_lib('delete_account')
createNewAccount = Cine.server_lib('create_new_account')

nameFromEmail = (herokuId)->
  herokuId.split('@')[0]

# herokuId: 'app6848@kensa.heroku.com'
# plan: 'free'
# callback(err, user, project)
exports.newAccount = (herokuId, plan, callback)->
  accountAttributes =
    herokuId: herokuId
    name: nameFromEmail(herokuId)
    plan: plan
    billingProviderName: 'heroku'
  projectAttributes =
    name: nameFromEmail(herokuId)
  userAttributes =
    email: herokuId
    name: nameFromEmail(herokuId)
  createNewAccount accountAttributes, userAttributes, projectAttributes, (err, results)->
    return callback(err) if err
    mailer.admin.newUser(results.user, 'heroku')
    callback(null, results.account, results.project)

# callback(err, user)
# This finds a user by email
#
exports.findUser = (accountId, userEmail, callback)->
  User.findOne email: userEmail, (err, user)->
    return callback(err) if err


    if !user
      Account.findById accountId, (err, account)->
        return callback(err) if err
        user = new User email: userEmail, plan: account.tempPlan, name: account.name
        user._accounts.push accountId
        console.log("CREATING USER", user)
        user.save callback
    else
      hasAccount = (userAccountId)->
        userAccountId.toString() == accountId.toString()
      # return the user if the user already
      return callback(null, user) if _.any user.accounts, hasAccount
      user._accounts.push accountId
      user.save callback

setPlanAndEnsureNotDeleted = (account, plan, callback)->
  account.deletedAt = undefined
  account.tempPlan = plan
  account.save (err, account)->
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
