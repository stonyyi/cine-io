environment = require('../config/environment')
Cine = require '../config/cine'
User = Cine.server_model('user')
Account = Cine.server_model('account')
require "mongoose-querystream-worker"

createAccount = (user, callback)->
  # assume one account/user as that's what we used to support
  if user._accounts.length > 0
    console.log('skipping', user._id)
    return callback()

  console.log('creating account for', user._id)
  userAccount = new Account

    tempPlan: user.plan
    stripeCustomer: user.stripeCustomer
    herokuId: user.herokuId
    masterKey: user.masterKey
  userAccount._id = user._id

  userAccount.save (err, account)->
    return callback(err) if err
    user._accounts.push account._id
    user.save callback

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

scope = User.find()

scope.stream().concurrency(20).work createAccount, endFunction
