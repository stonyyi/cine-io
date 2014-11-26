_ = require('underscore')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
ProvidersAndPlans = Cine.require('config/providers_and_plans')
UsageReport = Cine.model('usage_report')
humanizeBytes = Cine.lib('humanize_bytes')
getDaysInMonth = Cine.server_lib('get_days_in_month')

ARITRARY_OVERAGE_COST = 100 #one dollar

accountPlanAmount = (account)->
  plans = ProvidersAndPlans[account.billingProvider].plans
  addPlanAmount = (accum, plan)->
    accum + (plans[plan].price * 100)
  _.inject account.plans, addPlanAmount, 0

accountIsCreatedInThisMonth = (account, monthToBill)->
  account.createdAt.getYear() == monthToBill.getYear() && account.createdAt.getMonth() == monthToBill.getMonth()

shouldProrateNewAccounts = (account, monthToBill, accountUsageResult)->
  accountIsCreatedInThisMonth(account, monthToBill) && accountLessThan1GibUsage(accountUsageResult)

accountLessThan1GibUsage = (accountUsageResult)->
  accountUsageResult.bandwidth < humanizeBytes.GiB && accountUsageResult.storage < humanizeBytes.GiB

proratedAccountPlanAmount = (account, accountUsageResult)->
  daysInMonth = getDaysInMonth(account.createdAt)
  percentOfMonthAccountWasActive = (daysInMonth - (account.createdAt.getDate() - 1)) / daysInMonth
  accountPlanAmount(account) * percentOfMonthAccountWasActive

# returns
#  plan: Number in cents
#  storageOverage: Number in cents
#  bandwidthOverage: Number in cents
module.exports = (account, monthToBill, callback)->
  if account.plans.length == 0
    return callback null,
      billing:
        plan: 0
        prorated: false
      usage:
        bandwidth: 0
        storage: 0
  calculateAccountUsage.byMonth account, monthToBill, (err, accountUsageResult)->
    return callback(err) if err
    prorate = shouldProrateNewAccounts(account, monthToBill, accountUsageResult)
    planBill = if prorate then proratedAccountPlanAmount(account, accountUsageResult) else accountPlanAmount(account)
    result =
      billing:
        plan: planBill
        prorated: prorate
      usage:
        bandwidth: accountUsageResult['bandwidth']
        storage: accountUsageResult['storage']
    callback(null, result)

module.exports.accountPlanAmount = accountPlanAmount
