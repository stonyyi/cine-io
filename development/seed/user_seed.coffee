User = Cine.server_model 'user'
async = require 'async'
_ = require 'underscore'
createNewAccount = Cine.server_lib('create_new_account')

adminMaker = (name, callback)->
  accountAttributes =
    productPlans:
      broadcast: 'pro'
    billingProvider: 'cine.io'
    unthrottleable: true
  userAttributes =
    email: "#{name}@cine.io"
    name: name
    isSiteAdmin: true
    cleartextPassword: 'cine'
  createNewAccount accountAttributes, userAttributes, callback

module.exports = (callback)->
  console.log('creating users')
  async.parallel [(callback) ->
    adminMaker('thomas', callback)
  , (callback) ->
    adminMaker('jeffrey', callback)
  ], callback
