# Usage
# heroku run --app=cine-io coffee script/account_plan_count.coffee
# coffee script/account_plan_count.coffee

environment = require('../config/environment')
Cine.config('connect_to_mongo')
Account = Cine.server_model('account')
humanizeBytes = Cine.lib('humanize_bytes')

_ = require('underscore')

endFunction = (err, aggregate)->
  if err
    console.log("ending err", err)
    process.exit(1)
  process.exit(0)


# TODO: Don't know if this works now
aggregateQuery = [
  {$unwind: "$productPlans.broadcast"},
  {$group: {_id: "$productPlans.broadcast", planCount: {$sum: 1}}}
]

Account.aggregate(aggregateQuery).exec (err, aggregate)->
  return endFunction(err) if err

  planToCount = (accum, aggrResult)->
    accum[aggrResult._id] = aggrResult.planCount
    accum
  result = _.reduce aggregate, planToCount, {}
  console.log("Plan count", result)
  endFunction()
