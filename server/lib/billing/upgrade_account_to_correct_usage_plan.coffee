UsageReport = Cine.model('usage_report')
mailer = Cine.server_lib("mailer")
ProvidersAndPlans = Cine.require('config/providers_and_plans')

callLater = (callback, args...)->
  return process.nextTick ->
    callback(args...)

module.exports = (account, results, callback)->
  return callLater(callback, "cannot upgrade non cine.io accounts") if account.billingProvider != 'cine.io'
  lowestBandwidthPlan = UsageReport.lowestPlanPerUsage(results.bandwidth || 0, 'bandwidth', 'broadcast')
  lowestStoragePlan = UsageReport.lowestPlanPerUsage(results.storage || 0, 'storage', 'broadcast')
  console.log("got new plans", lowestBandwidthPlan, lowestStoragePlan)
  return callLater(callback, "Could not calculate lowestBandwidthPlan") unless lowestBandwidthPlan
  return callLater(callback, "Could not calculate lowestStoragePlan") unless lowestStoragePlan

  lowestBandwidthPlan = ProvidersAndPlans['cine.io'].broadcast.plans[lowestBandwidthPlan]
  lowestStoragePlan = ProvidersAndPlans['cine.io'].broadcast.plans[lowestStoragePlan]
  accountBroadcastPlan = ProvidersAndPlans['cine.io'].broadcast.plans[account.productPlans.broadcast[0]]
  newAccountPlanCandidate = if lowestBandwidthPlan.price > lowestStoragePlan.price then lowestBandwidthPlan else lowestStoragePlan

  if newAccountPlanCandidate.price > accountBroadcastPlan.price
    oldPlans = account.productPlans.broadcast
    account.productPlans.broadcast = [newAccountPlanCandidate.name]
    account.save (err, account)->
      return callback(err) if err
      mailer.admin.automaticallyUpgradedAccount account
      mailer.automaticallyUpgradedAccount account, oldPlans, (err)->
        callback err, account
  else
    callLater callback, null, account
