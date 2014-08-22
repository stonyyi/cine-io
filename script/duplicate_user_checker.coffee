environment = require('../config/environment')
Cine = require '../config/cine'
User = Cine.server_model('user')
_ = require('underscore')

endFunction = (err, aggregate)->
  if err
    console.log("ending err", err)
    process.exit(1)
  process.exit(0)


User.aggregate([
  { $group: {
    _id: { email: "$email" },
    uniqueIds: { $addToSet: "$_id" },
    count: { $sum: 1 }
  }},
  { $match: {
    count: { $gt: 1 }
  }}
]).exec (err, aggregate)->
  return endFunction(err) if err
  planToCount = (accum, aggrResult)->
    accum[aggrResult._id.email] = aggrResult.uniqueIds
    accum
  result = _.reduce aggregate, planToCount, {}
  console.log("results", result)
  endFunction()
