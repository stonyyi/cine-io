_ = require('underscore')
Account = Cine.server_model('account')
require "mongoose-querystream-worker"
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
humanizeBytes = Cine.lib('humanize_bytes')
UsageReport = Cine.model('usage_report')
BackboneAccount = Cine.model('account')
mailer = Cine.server_lib("mailer")

underFreePlanStorageAndBandwidth = (results)->
  results.storage <= humanizeBytes.GiB && results.bandwidth <= humanizeBytes.GiB

hasPrimaryCard = (account)->
  _.findWhere(account.stripeCustomer.cards, deletedAt: undefined)?

haveAndNeedCreditCard = (account)->
  account.billingProvider == 'cine.io' && account.stripeCustomer.stripeCustomerId? && hasPrimaryCard(account)

accountWithinLimit = (account, results)->
  ba = new BackboneAccount(provider: account.billingProvider, plans: account.plans)

  maxBandwidth = UsageReport.maxUsagePerAccount ba, 'bandwidth'
  maxStorage = UsageReport.maxUsagePerAccount ba, 'storage'
  results.bandwidth <= maxBandwidth && results.storage <= maxStorage

throttleAccount = (account, callback)->
  console.log("Throttling", account)

  account.throttledAt = new Date
  account.save (err, account)->
    return callback(err) if err
    mailer.throttledAccount account, callback

checkAccount = (account, callback)->
  # account has a credit card
  return callback() if haveAndNeedCreditCard(account)
  # need to check account usage
  calculateAccountUsage.thisMonth account, (err, results)->
    return callback(err) if err
    # it's cool if an account is < 1 GiB, no need to throttle them
    return callback() if underFreePlanStorageAndBandwidth(results)
    # if an account usage is over 1 gib, and they're a cine.io user, throttle them
    return throttleAccount(account, callback) if account.billingProvider == 'cine.io'
    # if the account is not a cine.io account, and they are within limits
    # that's cool
    return callback() if accountWithinLimit(account, results)
    # the account must not be within limits and we cannot charge overages
    throttleAccount(account, callback)
module.exports = (callback)->
  scope = Account.find().exists('deletedAt', false).exists('throttledAt', false)
  scope.stream().concurrency(20).work checkAccount, callback
