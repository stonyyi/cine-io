_ = require('underscore')
Account = Cine.server_model('account')
require "mongoose-querystream-worker"
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
upgradeAccountToCorrectUsagePlan = Cine.server_lib('billing/upgrade_account_to_correct_usage_plan')
humanizeBytes = Cine.lib('humanize_bytes')
UsageReport = Cine.model('usage_report')
BackboneAccount = Cine.model('account')
AccountEmailHistory = Cine.server_model("account_email_history")
mailer = Cine.server_lib("mailer")
AccountThrottler = Cine.server_lib('account_throttler')

MINUTES = 60 * 1000

underFreePlanStorageAndBandwidthAndPeer = (results)->
  underFreeBandwidth = if results.bandwidth then results.bandwidth <= humanizeBytes.GiB else true
  underFreeStorage = if results.storage then results.storage <= humanizeBytes.GiB else true
  # underFreePeer = if results.peerMilliseconds then results.peerMilliseconds <= (60 * MINUTES) else true
  underFreePeer = true

  underFreeBandwidth && underFreeStorage && underFreePeer

hasPrimaryCard = (account)->
  account.stripeCustomer.stripeCustomerId? && _.findWhere(account.stripeCustomer.cards, deletedAt: undefined)?

backboneAccountFromMongooseAccount = (account)->
  new BackboneAccount(provider: account.billingProvider, productPlans: account.productPlans)

calculateAccountLimit = (account, results)->
  ba = backboneAccountFromMongooseAccount(account)

  maxBandwidth = UsageReport.maxUsagePerAccount(ba, 'bandwidth', 'broadcast')
  maxStorage = UsageReport.maxUsagePerAccount(ba, 'storage', 'broadcast')
  maxPeerMilliseconds = UsageReport.maxUsagePerAccount(ba, 'minutes', 'peer')
  response =
    maxBandwidth: maxBandwidth
    maxStorage: maxStorage
    bandwidthPercent: results.bandwidth / maxBandwidth
    storagePercent: results.storage / maxStorage
    peerMillisecondsPercent: results.peerMilliseconds / maxPeerMilliseconds
  return response
  # results.bandwidth <= maxBandwidth && results.storage <= maxStorage

throttleAccount = (account, callback)->
  # console.log("Throttling", account)
  AccountThrottler.throttle account, 'overLimit', (err, account)->
    return callback(err) if err
    mailer.admin.throttledAccount account
    mailer.throttledAccount account, callback

overAccountLimit = (accountLimitResults)->
  accountLimitResults.bandwidthPercent > 1 ||
  accountLimitResults.storagePercent > 1 #||
  # accountLimitResults.peerMillisecondsPercent > 1

at90PercentOfAccountLimit = (accountLimitResults)->
  # console.log("accountLimitResults", accountLimitResults)
  accountLimitResults.bandwidthPercent > 0.9        ||
  accountLimitResults.storagePercent > 0.9         # ||
  # accountLimitResults.peerMillisecondsPercent > 0.9

isCineAccount = (account)->
  account.billingProvider == 'cine.io'

notifyUserTheyWillBeUpgraded = (date, account, results, callback)->
  AccountEmailHistory.findOrCreate _account: account._id, (err, aeh)->
    return callback() if aeh.recordForMonth(date, 'willUpgradeAccount')
    ba = backboneAccountFromMongooseAccount(account)
    nextPlan = UsageReport.nextPlan(ba, 'broadcast')
    mailer.admin.willUpgradeAccount account, nextPlan
    mailer.willUpgradeAccount account, nextPlan, (err)->
      return callback(err) if err
      aeh.history.push
        kind: 'willUpgradeAccount'
        sentAt: new Date
      aeh.save callback

checkAccount = (account, callback)->
  date = new Date
  calculateAccountUsage.thisMonth account, (err, results)->
    # console.log("calculated", err, results)
    return callback(err) if err

    # it's cool if an account is < 1 GiB and < 60 minutes for peer, no need to check anything
    return callback() if underFreePlanStorageAndBandwidthAndPeer(results)

    accountLimit = calculateAccountLimit(account, results)
    console.log("calculated account limit", accountLimit)
    if isCineAccount(account)
      # they have no credit card, throttle them
      unless hasPrimaryCard(account)
        # console.log("THROTTLEING")
        return throttleAccount(account, callback)
      # over account limit, upgrade their account
      if overAccountLimit(accountLimit)
        # console.log("UPGRADE")
        return upgradeAccountToCorrectUsagePlan(account, results, callback)
      # within 90 percent, notify them they will be upgraded
      if at90PercentOfAccountLimit(accountLimit)
        # console.log("NOTIFY")
        return notifyUserTheyWillBeUpgraded(date, account, results, callback)
      # all good, carry on
      # console.log("ALL GOOD")
      callback()
    else # not a cine.io account
      # throttle if they are over the account limit
      if overAccountLimit(accountLimit)
        # console.log("THROTTLING")
        return throttleAccount(account, callback)
      # not over acccount limit, carry on
      # console.log("ALL GOOD")
      callback()

module.exports = (callback)->
  scope = Account.find()
    .exists('deletedAt', false)
    .exists('throttledAt', false)
    .exists('unthrottleable', false)
  scope.stream().concurrency(20).work checkAccount, callback
