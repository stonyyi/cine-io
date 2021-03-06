debug = require('debug')('cine:create_new_account')
Account = Cine.server_model("account")
User = Cine.server_model("user")
Project = Cine.server_model("project")
_ = require('underscore')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
createTurnUserForProject = Cine.server_lib('coturn/create_turn_user_for_project')
_str = require('underscore.string')

# callback(err, user)
addUserToAccount = (account, userAttributes, callback)->
  return process.nextTick(callback) unless userAttributes.email
  User.findOne email: userAttributes.email, (err, user)->
    return callback(err) if err
    if user
      user.appdirectUUID ||= userAttributes.appdirectUUID
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

addProjectToAccount = (account, projectAttributes, streamAttributes, callback)->
  project = new Project name: projectAttributes.name, _account: account._id
  project.save (err, project)->
    return callback(err) if err
    createTurnUserForProject project, (err)->
      return callback(err) if err
      if account.productPlans?.broadcast?.length > 0
        # with broadcast plan
        addNextStreamToProject project, name: streamAttributes.name, (err, stream)->
          callback(err, stream: stream, project: project)
      else
        # no broadcast plan
        callback(null, project: project)

# callback err, project: project, stream: stream
addFirstProjectToAccount = (account, projectAttributes, streamAttributes, callback)->
  projectAttributes.name ||= "First Project"
  streamAttributes.name ||= "First Stream"
  addProjectToAccount account, projectAttributes, streamAttributes, callback

# callback: err, {account: Account, user: User, project: Project, stream: Stream}
module.exports = (accountAttributes, userAttributes={}, projectAttributes={}, streamAttributes={}, callback)->
  if _.isFunction(userAttributes)
    callback = userAttributes
    userAttributes = {}
    projectAttributes = {}
    streamAttributes = {}
  else if _.isFunction(projectAttributes)
    callback = projectAttributes
    projectAttributes = {}
    streamAttributes = {}
  else if _.isFunction(streamAttributes)
    callback = streamAttributes
    streamAttributes = {}

  return callback('Account creation disabled') if process.env.SHUTTING_DOWN
  # trim any whitespace
  userAttributes.email = _str.trim(userAttributes.email)

  productPlans = {broadcast: [], peer: []}
  if accountAttributes.productPlans
    productPlans.broadcast.push(accountAttributes.productPlans.broadcast) if accountAttributes.productPlans.broadcast
    productPlans.peer.push(accountAttributes.productPlans.peer) if accountAttributes.productPlans.peer

  accountAttributes.productPlans = productPlans

  accountAttributes.name ||= userAttributes.name
  accountAttributes.billingEmail ||= userAttributes.email
  results = {}

  account = new Account(accountAttributes)
  account.save (err, account)->
    return callback(err) if err
    results.account = account
    userAttributes.masterKey = account.masterKey
    addUserToAccount account, userAttributes, (err, user)->
      return callback(err) if err
      results.user = user if user
      addFirstProjectToAccount account, projectAttributes, streamAttributes, (err, projectAndStream)->
        # debug("done results", results)
        # we still want to allow the user to be created even if there is no stream
        err = null if err == 'Next stream not available, please try again later'
        return callback(err) if err

        results.project = projectAndStream.project if projectAndStream.project
        results.stream = projectAndStream.stream if projectAndStream.stream
        callback(null, results)

