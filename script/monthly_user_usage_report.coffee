environment = require('../config/environment')
Cine = require '../config/cine'
User = Cine.server_model('user')
require "mongoose-querystream-worker"
CalculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')

thisMonth = new Date

dateString = process.argv[2]
thisMonth = new Date(dateString) if dateString

console.log("Calculating for month of", thisMonth)

calculateUsage = (user, callback)->
  CalculateAccountUsage.byMonth user, thisMonth, (err, monthlyBytes)->
    if err
      console.log("ERROR CALCULATING USAGE", err)
      return callback(err)
    console.log("Total account usage for", user._id, user.email, monthlyBytes, "bytes")
    callback()

endFunction = (err)->
  console.log('ending')
  console.log("ending err", err) if err
  process.exit(0)

scope = User.find()
scope.stream().concurrency(20).work calculateUsage, endFunction
