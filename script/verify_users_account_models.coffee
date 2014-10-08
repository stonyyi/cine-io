environment = require('../config/environment')
Cine.config('connect_to_mongo')
User = Cine.server_model('user')
Account = Cine.server_model('account')
require "mongoose-querystream-worker"
_ = require('underscore')
verifyAccount = (user, callback)->
  # assume one account/user as that's what we used to support
  if user._accounts.length != 1
    console.log('THIS IS BROKEN', user._id)
    return callback()
  accountId = user._accounts[0]
  Account.findById accountId, (err, account)->
    return callback(err) if err
    console.log("BROKEN plan", user._id) if user.plan != account.tempPlan
    console.log("BROKEN masterKey", user._id) if user.masterKey != account.masterKey
    console.log("BROKEN herokuId", user._id) if user.herokuId != account.herokuId
    console.log("CHECK STRIPE CUSTOMER", user._id, account._id) if user.stripeCustomer.stripeCustomerId
    console.log("NOT SAME ID", user._id) if user._id.toString() != account._id.toString()

    callback()

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

scope = User.find()

scope.stream().concurrency(20).work verifyAccount, endFunction
