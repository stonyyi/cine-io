# Usage
# heroku run --app=cine-io coffee script/account_usage_report.coffee compact humanize
# coffee script/account_usage_report.coffee
# coffee script/account_usage_report.coffee all # does every month
# coffee script/account_usage_report.coffee 2014-01
# coffee script/account_usage_report.coffee humanize
# coffee script/account_usage_report.coffee compact # removes 0 bytes accounts
# coffee script/account_usage_report.coffee all humanize
# coffee script/account_usage_report.coffee 2014-01 humanize
# coffee script/account_usage_report.coffee 2014-01 compact
# coffee script/account_usage_report.coffee all compact
# coffee script/account_usage_report.coffee humanize compact
# coffee script/account_usage_report.coffee all humanize compact
# coffee script/account_usage_report.coffee 2014-01 humanize compact

environment = require('../config/environment')
Cine = require '../config/cine'
require "mongoose-querystream-worker"
moment = require('moment')
Account = Cine.server_model('account')
CalculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
humanizeBytes = Cine.lib('humanize_bytes')

_ = require('underscore')
totalAccountsLogged = 0

callbackFunction = (account, callback)->
  return (err, collectedBytes)->
    if err
      console.log("ERROR CALCULATING USAGE", err)
      return callback(err)

    return callback() if shouldCompact && collectedBytes == 0

    byteString = if shouldHumanize then humanizeBytes(collectedBytes) else "#{collectedBytes} bytes"
    console.log("Total account usage for", account._id, account.billingEmail || account.herokuId, account.billingProvider, byteString)
    totalAccountsLogged += 1
    callback()

calculateMonthlyUsage = (account, callback)->
  CalculateAccountUsage.byMonth account, thisMonth, callbackFunction(account, callback)

calculateTotalUsage = (account, callback)->
  CalculateAccountUsage.total account, callbackFunction(account, callback)

endFunction = (err)->
  console.log("For a total of #{totalAccountsLogged} accounts.")
  console.log("ending err", err) if err
  process.exit(0)

scope = Account.find()

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
    console.log("Calculating all account bandwidth.")
  when 'monthly'
    workFunction = calculateMonthlyUsage
    console.log("Calculating for month of #{moment(thisMonth).format("MMM YYYY")}.")

scope.stream().concurrency(20).work workFunction, endFunction
