Account = Cine.server_model("account")
User = Cine.server_model("user")
Project = Cine.server_model("project")
_ = require('underscore')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')

# callback(err, user)
addUserToAccount = (account, userAttributes, callback)->
  User.findOne email: userAttributes.email, (err, user)->
    return callback(err) if err
    user = new User(userAttributes) unless user

    user._accounts.push(account._id)
    return user.save callback

addProjectToAccount = (account, user, projectAttributes, streamAttributes, callback)->
  project = new Project name: projectAttributes.name, _account: account._id
  project.save (err, project)->
    return callback(err) if err

    # TODO REMOVE THIS, AFTER ACCOUNT MIGRATION IS DONE
    addProjectToUser user, project, (err)->
      return callback(err) if err

      addNextStreamToProject project, name: streamAttributes.name, (err, stream)->
        return callback(err) if err
        callback(null, stream: stream, project: project)

# callback err, project: project, stream: stream
addFirstProjectToAccount = (account, user, projectAttributes, streamAttributes, callback)->
  projectAttributes.name ||= "First Project"
  streamAttributes.name ||= "First Stream"
  addProjectToAccount account, user, projectAttributes, streamAttributes, callback

addProjectToUser = (user, project, callback)->
  user.permissions.push objectId: project._id, objectName: 'Project'
  user.save callback

# callback: err, {account: Account, user: User, project: Project, stream: Stream}
module.exports = (accountAttributes, userAttributes, projectAttributes={}, streamAttributes={}, callback)->
  if _.isFunction(projectAttributes)
    callback = projectAttributes
    projectAttributes = {}
    streamAttributes = {}
  else if _.isFunction(streamAttributes)
    callback = streamAttributes
    streamAttributes = {}

  userAttributes.plan = accountAttributes.plan
  userAttributes.herokuId = accountAttributes.herokuId
  userAttributes.herokuId = accountAttributes.herokuId

  account = new Account(accountAttributes)
  account.save (err, account)->
    return callback(err) if err
    addUserToAccount account, userAttributes, (err, user)->
      return callback(err) if err
      addFirstProjectToAccount account, user, projectAttributes, streamAttributes, (err, results)->
        return callback(err) if err
        # console.log("done results", results)
        callback(null, account: account, user: user, project: results.project, stream: results.stream)
