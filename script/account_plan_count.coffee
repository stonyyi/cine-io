# Usage
# heroku run --app=cine-io coffee script/account_plan_count.coffee
# coffee script/account_plan_count.coffee

environment = require('../config/environment')
Cine = require '../config/cine'
Account = Cine.server_model('account')
humanizeBytes = Cine.lib('humanize_bytes')

_ = require('underscore')

endFunction = (err, aggregate)->
  if err
    console.log("ending err", err)
    process.exit(1)
  process.exit(0)

Account.aggregate({$group: {_id: {tempPlan: "$tempPlan"}, planCount: {$sum: 1}} }).exec (err, aggregate)->
  return endFunction(err) if err
  planToCount = (accum, aggrResult)->
    accum[aggrResult._id.tempPlan] = aggrResult.planCount
    accum
  result = _.reduce aggregate, planToCount, {}
  console.log("Plan count", result)
  endFunction()
