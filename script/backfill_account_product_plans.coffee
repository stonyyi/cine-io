environment = require('../config/environment')
Cine.config('connect_to_mongo')
Account = Cine.server_model('account')
require "mongoose-querystream-worker"

backfillAccountPlans = (account, callback)->
  console.log('backfill broadcast plans for', account._id)
  account.productPlans.broadcast = account.plans
  account.save callback

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

scope = Account.find()

scope.stream().concurrency(20).work backfillAccountPlans, endFunction
