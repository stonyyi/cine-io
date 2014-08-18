environment = require('../config/environment')
Cine = require '../config/cine'
require "mongoose-querystream-worker"
User = Cine.server_model('user')
Project = Cine.server_model('project')
Account = Cine.server_model('account')
_ = require('underscore')

addAccount = (project, callback)->
  # assume one account/user as that's what we used to support
  if project._account
    console.log('skipping', project._id)
    return callback()

  console.log('creating account for', project._id)
  query =
    "permissions.objectId": project._id
    "permissions.objectName": "Project"

  User.find query, (err, users)->
    return callback(err) if err
    if users.length > 1
      console.log("THESE USERS SHARE A PROJECT", project._id, _.pluck(users, '_id'))
    user = users[0]
    unless user
      console.log("Cannot find user", query)
      return callback("NO USER FOUND")
    console.log("found user", user._id)
    project._account = user._accounts[0]
    project.save callback

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

scope = Project.find()

scope.stream().concurrency(20).work addAccount, endFunction
