environment = require('../config/environment')
Cine = require '../config/cine'
Account = Cine.server_model('account')
require "mongoose-querystream-worker"

backfillAccountPlans = (account, callback)->
  # assume one account/user as that's what we used to support
  console.log('backfill plan for', account._id)
  account.plans = [account.tempPlan]
  account.save callback

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

scope = Account.find()

scope.stream().concurrency(20).work backfillAccountPlans, endFunction
