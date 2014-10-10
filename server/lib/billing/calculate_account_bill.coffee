_ = require('underscore')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
ProvidersAndPlans = Cine.require('config/providers_and_plans')
UsageReport = Cine.model('usage_report')
BackboneAccount = Cine.model('account')
humanizeBytes = Cine.lib('humanize_bytes')

accountPlanAmount = (account)->
  plans = ProvidersAndPlans[account.billingProvider].plans
  addPlanAmount = (accum, plan)->
    accum + plans[plan].price
  _.inject account.plans, addPlanAmount, 0

accountOverageFee = (account, plan, type)->
  ProvidersAndPlans[account.billingProvider].plans[plan]["#{type}Overage"]

cheapestOverageCost = (account, type)->
  cheapestOveragePlan = accountOverageFee(account, _.first(account.plans), type)
  _.each account.plans, (plan)->
    thisPlanOverage = accountOverageFee(account, plan, type)
    cheapestOveragePlan = thisPlanOverage if thisPlanOverage < cheapestOveragePlan
  # return in cents
  cheapestOveragePlan * 100

calculateAccountOverage = (account, accountUsageResult, type)->
  # HACK for the difference between mongoose model vs backbone model
  ba = new BackboneAccount(provider: account.billingProvider, plans: account.plans)

  maxAmount = UsageReport.maxUsagePerAccount ba, type
  usedAmount = accountUsageResult[type]
  overage = usedAmount - maxAmount
  return 0 if overage <= 0
  overageInGib = overage / humanizeBytes.GiB
  return overageInGib * cheapestOverageCost(account, type)

calculateStorageOverage = (account)->
  return 0

# returns
#  plan: Number in cents
#  storageOverage: Number in cents
#  bandwidthOverage: Number in cents
module.exports = (account, callback)->
  calculateAccountUsage.thisMonth account, (err, accountUsageResult)->
    return callback(err) if err
    result =
      plan: accountPlanAmount(account)
      bandwidthOverage: calculateAccountOverage(account, accountUsageResult, 'bandwidth')
      storageOverage: calculateAccountOverage(account, accountUsageResult, 'storage')
    callback(null, result)