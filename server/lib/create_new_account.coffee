Account = Cine.server_model("account")
User = Cine.server_model("user")
Project = Cine.server_model("project")
BillingProvider = Cine.server_model('billing_provider')
_ = require('underscore')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')

# callback(err, user)


addUserToAccount = (account, userAttributes, callback)->
  User.findOne email: userAttributes.email, (err, user)->
    return callback(err) if err
    if user
      user._accounts.push account._id
      return user.save callback
    else
      user = new User(userAttributes)
      cleartextPassword = userAttributes.cleartextPassword
      user._accounts.push(account._id)
      return user.save(callback) unless cleartextPassword
      user.assignHashedPasswordAndSalt cleartextPassword, (err)->
        return callback(err) if err
        return user.save callback

addProjectToAccount = (account, user, projectAttributes, streamAttributes, callback)->
  project = new Project name: projectAttributes.name, _account: account._id
  project.save (err, project)->
    return callback(err) if err

    addNextStreamToProject project, name: streamAttributes.name, (err, stream)->
      callback(err, stream: stream, project: project)

# callback err, project: project, stream: stream
addFirstProjectToAccount = (account, user, projectAttributes, streamAttributes, callback)->
  projectAttributes.name ||= "First Project"
  streamAttributes.name ||= "First Stream"
  addProjectToAccount account, user, projectAttributes, streamAttributes, callback

# callback: err, {account: Account, user: User, project: Project, stream: Stream}
module.exports = (accountAttributes, userAttributes, projectAttributes={}, streamAttributes={}, callback)->
  if _.isFunction(projectAttributes)
    callback = projectAttributes
    projectAttributes = {}
    streamAttributes = {}
  else if _.isFunction(streamAttributes)
    callback = streamAttributes
    streamAttributes = {}

  accountAttributes.tempPlan = accountAttributes.plan
  accountAttributes.billingEmail ||= userAttributes.email
  go = ->
    account = new Account(accountAttributes)
    account.save (err, account)->
      return callback(err) if err
      userAttributes.masterKey = account.masterKey
      addUserToAccount account, userAttributes, (err, user)->
        return callback(err) if err
        addFirstProjectToAccount account, user, projectAttributes, streamAttributes, (err, results)->
          # console.log("done results", results)
          # we still want to allow the user to be created even if there is no stream
          err = null if err == 'Next stream not available, please try again later'
          callback(err, account: account, user: user, project: results.project, stream: results.stream)
  if accountAttributes.billingProviderName
    BillingProvider.findOne name: accountAttributes.billingProviderName, (err, billingProvider)->
      return callback(err) if err
      accountAttributes._billingProvider = billingProvider._id if billingProvider
      go()

  else
    go()
