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
  lowestPeerMillisecondsPlan = UsageReport.lowestPlanPerUsage(results.peerMilliseconds || 0, 'minutes', 'peer')
  return callLater(callback, "Could not calculate lowestBandwidthPlan") unless lowestBandwidthPlan
  return callLater(callback, "Could not calculate lowestStoragePlan") unless lowestStoragePlan
  return callLater(callback, "Could not calculate lowestPeerMillisecondsPlan") unless lowestPeerMillisecondsPlan

  lowestBandwidthPlan = ProvidersAndPlans['cine.io'].broadcast.plans[lowestBandwidthPlan]
  lowestStoragePlan = ProvidersAndPlans['cine.io'].broadcast.plans[lowestStoragePlan]
  lowestPeerMillisecondsPlan = ProvidersAndPlans['cine.io'].peer.plans[lowestPeerMillisecondsPlan]

  accountBroadcastPlan = ProvidersAndPlans['cine.io'].broadcast.plans[account.productPlans.broadcast[0]]
  accountPeerPlan = ProvidersAndPlans['cine.io'].peer.plans[account.productPlans.peer[0]]
  newBroadcastAccountPlanCandidate = if lowestBandwidthPlan.price > lowestStoragePlan.price then lowestBandwidthPlan else lowestStoragePlan

  updated = false
  if accountBroadcastPlan && newBroadcastAccountPlanCandidate.price > accountBroadcastPlan.price
    updated = true
    oldBroadcastPlans = account.productPlans.broadcast
    account.productPlans.broadcast = [newBroadcastAccountPlanCandidate.name]
  if accountPeerPlan && lowestPeerMillisecondsPlan.price > accountPeerPlan.price
    updated = true
    oldPeerPlans = account.productPlans.peer
    account.productPlans.peer = [lowestPeerMillisecondsPlan.name]

  if updated
    account.save (err, account)->
      return callback(err) if err
      mailer.admin.automaticallyUpgradedAccount account
      mailer.automaticallyUpgradedAccount account, broadcast: oldBroadcastPlans, peer: oldPeerPlans, (err)->
        callback err, account
  else
    callLater callback, null, account
