environment = require('../config/environment')
Cine = require '../config/cine'
User = Cine.server_model('user')
Account = Cine.server_model('account')
require "mongoose-querystream-worker"
async = require('async')

backfillBillingEmail = (user, callback)->
  # assume one account/user as that's what we used to support
  console.log('backfill billing email for', user._id)

  setBillingEmailToUserEmail = (accountId, cb)->
    return cb(null) unless user.email
    Account.findById accountId, (err, account)->
      return cb(err) if err
      return cb(null) if account.billingEmail
      account.billingEmail = user.email
      account.save cb

  async.each user._accounts, setBillingEmailToUserEmail, callback

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

scope = User.find()

scope.stream().concurrency(20).work backfillBillingEmail, endFunction
