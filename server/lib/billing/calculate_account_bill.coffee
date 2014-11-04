_ = require('underscore')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
ProvidersAndPlans = Cine.require('config/providers_and_plans')
UsageReport = Cine.model('usage_report')
BackboneAccount = Cine.model('account')
humanizeBytes = Cine.lib('humanize_bytes')
getDaysInMonth = Cine.server_lib('get_days_in_month')

ARITRARY_OVERAGE_COST = 100 #one dollar

accountPlanAmount = (account)->
  plans = ProvidersAndPlans[account.billingProvider].plans
  addPlanAmount = (accum, plan)->
    accum + (plans[plan].price * 100)
  _.inject account.plans, addPlanAmount, 0

accountOverageFee = (account, plan, type)->
  ProvidersAndPlans[account.billingProvider].plans[plan]["#{type}Overage"]

cheapestOverageCost = (account, type)->
  cheapestOveragePlan = accountOverageFee(account, _.first(account.plans), type) || ARITRARY_OVERAGE_COST
  _.each account.plans, (plan)->
    thisPlanOverage = accountOverageFee(account, plan, type)
    cheapestOveragePlan = thisPlanOverage if thisPlanOverage < cheapestOveragePlan
  # return in cents
  cheapestOveragePlan * 100

calculateMaxUsage = (account, type)->
  # HACK for the difference between mongoose model vs backbone model
  ba = new BackboneAccount(provider: account.billingProvider, plans: account.plans)
  UsageReport.maxUsagePerAccount ba, type

calculateAccountOverage = (account, accountUsageResult, type)->
  maxAmount = calculateMaxUsage(account, type)
  usedAmount = accountUsageResult[type]
  overage = usedAmount - maxAmount
  # overage less than 0 means we used less than the max
  if overage <= 0 then 0 else overage

calculateAccountOverageCost = (account, overage, type)->
  overageInGib = overage / humanizeBytes.GiB
  return overageInGib * cheapestOverageCost(account, type)

accountIsCreatedInThisMonth = (account, monthToBill)->
  account.createdAt.getYear() == monthToBill.getYear() && account.createdAt.getMonth() == monthToBill.getMonth()

shouldProrateNewAccounts = (account, monthToBill, bandwidthOverage, storageOverage)->
  accountIsCreatedInThisMonth(account, monthToBill) && bandwidthOverage == 0 && storageOverage == 0

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
        bandwidthOverage: 0
        storageOverage: 0
        prorated: false
      usage:
        bandwidth: 0
        storage: 0
        bandwidthOverage: 0
        storageOverage: 0
  calculateAccountUsage.byMonth account, monthToBill, (err, accountUsageResult)->
    return callback(err) if err
    bandwidthOverage = calculateAccountOverage(account, accountUsageResult, 'bandwidth')
    storageOverage = calculateAccountOverage(account, accountUsageResult, 'storage')

    prorate = shouldProrateNewAccounts(account, monthToBill, bandwidthOverage, storageOverage)
    planBill = if prorate then proratedAccountPlanAmount(account, accountUsageResult) else accountPlanAmount(account)
    result =
      billing:
        plan: planBill
        bandwidthOverage: calculateAccountOverageCost(account, bandwidthOverage, 'bandwidth')
        storageOverage: calculateAccountOverageCost(account, storageOverage, 'bandwidth')
        prorated: prorate
      usage:
        bandwidth: accountUsageResult['bandwidth']
        storage: accountUsageResult['storage']
        bandwidthOverage: bandwidthOverage
        storageOverage: storageOverage
    callback(null, result)

module.exports.cheapestOverageCost = cheapestOverageCost
module.exports.accountPlanAmount = accountPlanAmount
