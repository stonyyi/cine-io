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
Cine.config('connect_to_mongo')
require "mongoose-querystream-worker"
moment = require('moment')
async = require('async')
Account = Cine.server_model('account')
CalculateAccountBandwidth = Cine.server_lib('reporting/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/calculate_account_storage')
humanizeBytes = Cine.lib('humanize_bytes')

_ = require('underscore')
totalAccountsLogged = 0

logOutput = (account, response, callback)->
  bandwidthBytes = response.bandwidth
  storageBytes = response.storage
  return callback() if shouldCompact && bandwidthBytes == 0 && storageBytes == 0
  accountUsage = {}
  if bandwidthBytes != 0
    accountUsage.bandwidth = if shouldHumanize then humanizeBytes(bandwidthBytes) else "#{bandwidthBytes} bytes"
  if storageBytes != 0
    accountUsage.storage = if shouldHumanize then humanizeBytes(storageBytes) else "#{storageBytes} bytes"
  console.log("Total account usage for", account._id, account.billingEmail || account.herokuId, account.billingProvider, accountUsage)
  totalAccountsLogged += 1
  callback()

calculateMonthlyUsage = (account, callback)->
  asyncCalls =
    bandwidth: (cb)->
      CalculateAccountBandwidth.byMonth account, thisMonth, cb
    storage: (cb)->
      CalculateAccountStorage.total account, cb
  async.parallel asyncCalls, (err, response)->
    return callback(err) if err
    logOutput(account, response, callback)

calculateTotalUsage = (account, callback)->
  asyncCalls =
    bandwidth: (cb)->
      CalculateAccountBandwidth.total account, cb
    storage: (cb)->
      CalculateAccountStorage.total account, cb
  async.parallel asyncCalls, (err, response)->
    return callback(err) if err
    logOutput(account, response, callback)

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
