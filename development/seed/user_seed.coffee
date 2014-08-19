User = Cine.server_model 'user'
async = require 'async'
_ = require 'underscore'
createNewAccount = Cine.server_lib('create_new_account')

adminMaker = (name, callback)->
  accountAttributes =
    plan: 'enterprise'
    billingProviderName: 'cine.io'
  userAttributes =
    email: "#{name}@cine.io"
    name: name
    permissions: [{objectName: 'site'}]
    cleartextPassword: 'cine'
  createNewAccount accountAttributes, userAttributes, (err, results)->
    return callback(err) if err
    callback(null, results.user)

module.exports = (callback)->
  console.log('creating users')
  async.parallel [(callback) ->
    adminMaker('thomas', callback)
  , (callback) ->
    adminMaker('jeffrey', callback)
  ], callback
