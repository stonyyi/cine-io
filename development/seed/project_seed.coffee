Project = Cine.server_model 'project'
User = Cine.server_model 'user'
async = require 'async'
_ = require('underscore')
# test stripe data
testStripeData =
  accessToken: "sk_test_sBQeSJFIxPi36BdCvUV9xVBN"
  refreshToken: "rt_3RCzgy1nNYZ9hWt0M5j6k8tcwKS1LB5vKCtWZMhjfSh9fIaz"
  stripeUserId: "acct_102czJ2AL5avr9E4"
  stripePublishableKey: "pk_test_ckE0OqfgahrU3Xje3RhMi0mV"

createProjectWithUsers = (users, attributes, callback)->
    project = new Project attributes
    project.save (err)->
      addPermission = (user, cb)->
        user.permissions.push objectId: project._id, objectName: 'Project'
        user.save cb
      async.each users, addPermission, (err)->
        callback(null, project)

module.exports = (users, cb)->
  console.log('creating projects')
  async.parallel [(callback) ->
    createProjectWithUsers(users, name: 'Giving Stage (Development)', plan: 'free', callback)
  , (callback) ->
    createProjectWithUsers(users, name: 'Giving Stage (Production)', plan: 'enterprise', callback)
  ], cb
