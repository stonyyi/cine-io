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

underFreePlanStorageAndBandwidth = (results)->
  results.storage <= humanizeBytes.GiB && results.bandwidth <= humanizeBytes.GiB

hasPrimaryCard = (account)->
  account.stripeCustomer.stripeCustomerId? && _.findWhere(account.stripeCustomer.cards, deletedAt: undefined)?

backboneAccountFromMongooseAccount = (account)->
  new BackboneAccount(provider: account.billingProvider, productPlans: account.productPlans)
calculateAccountLimit = (account, results)->
  ba = backboneAccountFromMongooseAccount(account)

  maxBandwidth = UsageReport.maxUsagePerAccount(ba, 'bandwidth', 'broadcast')
  maxStorage = UsageReport.maxUsagePerAccount(ba, 'storage', 'broadcast')
  response =
    maxBandwidth: maxBandwidth
    maxStorage: maxStorage
    bandwidthPercent: results.bandwidth / maxBandwidth
    storagePercent: results.storage / maxStorage
  return response
  # results.bandwidth <= maxBandwidth && results.storage <= maxStorage

throttleAccount = (account, callback)->
  console.log("Throttling", account)
  AccountThrottler.throttle account, 'overLimit', (err, account)->
    return callback(err) if err
    mailer.admin.throttledAccount account
    mailer.throttledAccount account, callback

overAccountLimit = (accountLimitResults)->
  accountLimitResults.bandwidthPercent > 1 || accountLimitResults.storagePercent > 1

at90PercentOfAccountLimit = (accountLimitResults)->
  accountLimitResults.bandwidthPercent > 0.9 || accountLimitResults.storagePercent > 0.9

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
    return callback(err) if err

    # it's cool if an account is < 1 GiB, no need to check anything
    return callback() if underFreePlanStorageAndBandwidth(results)

    accountLimit = calculateAccountLimit(account, results)

    if isCineAccount(account)
      # they have no credit card, throttle them
      return throttleAccount(account, callback) unless hasPrimaryCard(account)
      # over account limit, upgrade their account
      return upgradeAccountToCorrectUsagePlan(account, results, callback) if overAccountLimit(accountLimit)
      # within 90 percent, notify them they will be upgraded
      return notifyUserTheyWillBeUpgraded(date, account, results, callback) if at90PercentOfAccountLimit(accountLimit)
      # all good, carry on
      callback()
    else # not a cine.io account
      # throttle if they are over the account limit
      return throttleAccount(account, callback) if overAccountLimit(accountLimit)
      # not over acccount limit, carry on
      callback()

module.exports = (callback)->
  scope = Account.find()
    .exists('deletedAt', false)
    .exists('throttledAt', false)
    .exists('unthrottleable', false)
  scope.stream().concurrency(20).work checkAccount, callback
