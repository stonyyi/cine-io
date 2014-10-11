# Usage
# heroku run --app=cine-io coffee script/account_billing_report.coffee

environment = require('../config/environment')
Cine.config('connect_to_mongo')
require "mongoose-querystream-worker"
moment = require('moment')
async = require('async')
Account = Cine.server_model('account')
calculateAccountBill = Cine.server_lib('billing/calculate_account_bill')
humanizeBytes = Cine.lib('humanize_bytes')

_ = require('underscore')
totalAccountsLogged = 0
totalIncome = 0

logOutput = (account, response, callback)->
  return callback() if response.billing.plan == 0
  accountUsage = {}

  billing = response.billing
  monthlyBill = billing.plan + billing.bandwidthOverage + billing.storageOverage
  console.log("Total account bill for", account._id, account.billingEmail || account.herokuId, account.billingProvider, account.plans, "$#{monthlyBill / 100}")
  totalAccountsLogged += 1
  totalIncome += monthlyBill
  callback()

calculateMonthlyBilling = (account, callback)->
  calculateAccountBill account, (err, response)->
    return callback(err) if err
    logOutput(account, response, callback)

endFunction = (err)->
  console.log("ending err", err) if err
  console.log("Totalling $#{totalIncome / 100} from #{totalAccountsLogged} accounts.")
  process.exit(0)

scope = Account.find().exists('deletedAt', false)

thisMonth = new Date


workFunction = calculateMonthlyBilling
console.log("Calculating billing for month of #{moment(thisMonth).format("MMM YYYY")}.")

scope.stream().concurrency(20).work workFunction, endFunction
