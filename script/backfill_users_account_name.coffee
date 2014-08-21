environment = require('../config/environment')
Cine = require '../config/cine'
User = Cine.server_model('user')
Account = Cine.server_model('account')
require "mongoose-querystream-worker"
async = require('async')

backfillAccountName = (user, callback)->
  # assume one account/user as that's what we used to support
  console.log('backfill billing name for', user._id)

  setNameToUserName = (accountId, cb)->
    return cb(null) unless user.name
    Account.findById accountId, (err, account)->
      return cb(err) if err
      return cb(null) if account.name
      account.name = user.name
      account.save cb

  async.each user._accounts, setNameToUserName, callback

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

scope = User.find()

scope.stream().concurrency(20).work backfillAccountName, endFunction
