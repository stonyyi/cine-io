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

createProjectWithUsers = (accountsAndUsers, attributes, callback)->
  project = new Project attributes
  project._account = _.sample(accountsAndUsers).account._id
  project.save (err)->
    callback(null, project)

module.exports = (accountsAndUsers, cb)->
  console.log('creating projects')
  async.parallel [(callback) ->
    createProjectWithUsers(accountsAndUsers, name: 'Giving Stage (Development)', callback)
  , (callback) ->
    createProjectWithUsers(accountsAndUsers, name: 'Giving Stage (Production)', callback)
  ], cb
