UsageReport = Cine.model('usage_report')
mailer = Cine.server_lib("mailer")
ProvidersAndPlans = Cine.require('config/providers_and_plans')

callLater = (callback, args...)->
  return process.nextTick ->
    callback(args...)

module.exports = (account, results, callback)->
  return callLater(callback, "cannot upgrade non cine.io accounts") if account.billingProvider != 'cine.io'
  lowestBandwidthPlan = UsageReport.lowestPlanPerUsage(results.bandwidth || 0, 'bandwidth')
  lowestStoragePlan = UsageReport.lowestPlanPerUsage(results.storage || 0, 'storage')
  console.log("got new plans", lowestBandwidthPlan, lowestStoragePlan)
  return callLater(callback, "Could not calculate lowestBandwidthPlan") unless lowestBandwidthPlan
  return callLater(callback, "Could not calculate lowestStoragePlan") unless lowestStoragePlan

  lowestBandwidthPlan = ProvidersAndPlans['cine.io'].plans[lowestBandwidthPlan]
  lowestStoragePlan = ProvidersAndPlans['cine.io'].plans[lowestStoragePlan]
  accountPlan = ProvidersAndPlans['cine.io'].plans[account.plans[0]]
  newAccountPlanCandidate = if lowestBandwidthPlan.price > lowestStoragePlan.price then lowestBandwidthPlan else lowestStoragePlan

  if newAccountPlanCandidate.price > accountPlan.price
    oldPlans = account.plans
    account.plans = [newAccountPlanCandidate.name]
    account.save (err, account)->
      return callback(err) if err
      mailer.admin.automaticallyUpgradedAccount account
      mailer.automaticallyUpgradedAccount account, oldPlans, (err)->
        callback err, account
  else
    callLater callback, null, account
