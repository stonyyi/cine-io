# Usage
# coffee script/user_usage_report.coffee
# coffee script/user_usage_report.coffee all # does every month
# coffee script/user_usage_report.coffee 2014-01
# coffee script/user_usage_report.coffee humanize
# coffee script/user_usage_report.coffee compact # removes 0 bytes users
# coffee script/user_usage_report.coffee all humanize
# coffee script/user_usage_report.coffee 2014-01 humanize
# coffee script/user_usage_report.coffee 2014-01 compact
# coffee script/user_usage_report.coffee all compact
# coffee script/user_usage_report.coffee humanize compact
# coffee script/user_usage_report.coffee all humanize compact
# coffee script/user_usage_report.coffee 2014-01 humanize compact

environment = require('../config/environment')
Cine = require '../config/cine'
require "mongoose-querystream-worker"
moment = require('moment')
User = Cine.server_model('user')
CalculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
humanizeBytes = Cine.server_lib('humanize_bytes')
_ = require('underscore')

callbackFunction = (user, callback)->
  return (err, collectedBytes)->
    if err
      console.log("ERROR CALCULATING USAGE", err)
      return callback(err)

    return callback() if shouldCompact && collectedBytes == 0

    byteString = if shouldHumanize then humanizeBytes(collectedBytes) else "#{collectedBytes} bytes"
    console.log("Total account usage for", user._id, user.email, byteString)
    callback()

calculateMonthlyUsage = (user, callback)->
  CalculateAccountUsage.byMonth user, thisMonth, callbackFunction(user, callback)

calculateTotalUsage = (user, callback)->
  CalculateAccountUsage.total user, callbackFunction(user, callback)

endFunction = (err)->
  console.log('ending')
  console.log("ending err", err) if err
  process.exit(0)

scope = User.find()

dateString = process.argv[2]
shouldHumanize = _.any(process.argv, (arg)-> arg == 'humanize')
shouldCompact = _.any(process.argv, (arg)-> arg == 'compact')

type = 'monthly'
thisMonth = new Date

switch dateString
  when 'all'
    type = 'all'
  when 'humanize'
    shouldHumanize = true
  when 'compact'
    shouldCompact = true
  else
    if dateString
      type = 'monthly'
      thisMonth = new Date(dateString)

switch type
  when 'all'
    workFunction = calculateTotalUsage
    console.log("Calculating all user bandwidth.")
  when 'monthly'
    workFunction = calculateMonthlyUsage
    console.log("Calculating for month of #{moment(thisMonth).format("MMM YYYY")}.")

scope.stream().concurrency(20).work workFunction, endFunction
