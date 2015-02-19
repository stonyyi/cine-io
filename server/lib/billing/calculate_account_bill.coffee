debug = require('debug')('cine:calculate_account_bill')
_ = require('underscore')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
ProvidersAndPlans = Cine.require('config/providers_and_plans')
UsageReport = Cine.model('usage_report')
humanizeBytes = Cine.lib('humanize_bytes')
getDaysInMonth = Cine.server_lib('get_days_in_month')

ARITRARY_OVERAGE_COST = 100 #one dollar

accountPlanAmount = (account)->
  addPlanAmount = (product)->
    plans = ProvidersAndPlans[account.billingProvider][product].plans
    (accum, plan)->
      accum + (plans[plan].price * 100)
  broadcast = _.inject account.productPlans.broadcast, addPlanAmount('broadcast'), 0
  peer = _.inject account.productPlans.peer, addPlanAmount('peer'), 0
  debug("Adding", broadcast, peer)
  broadcast + peer

accountIsCreatedInThisMonth = (account, monthToBill)->
  account.createdAt.getYear() == monthToBill.getYear() && account.createdAt.getMonth() == monthToBill.getMonth()

shouldProrateNewAccounts = (account, monthToBill, accountUsageResult)->
  accountIsCreatedInThisMonth(account, monthToBill) && accountLessThan1GibUsage(accountUsageResult) && accountLessThan60MinutesUsage(accountUsageResult)

accountLessThan1GibUsage = (accountUsageResult)->
  accountUsageResult.bandwidth < humanizeBytes.GiB && accountUsageResult.storage < humanizeBytes.GiB

accountLessThan60MinutesUsage = (accountUsageResult)->
  oneHour = 60 * 60 * 1000
  accountUsageResult.peerMilliseconds < oneHour

proratedAccountPlanAmount = (account, accountUsageResult)->
  daysInMonth = getDaysInMonth(account.createdAt)
  percentOfMonthAccountWasActive = (daysInMonth - (account.createdAt.getDate() - 1)) / daysInMonth
  accountPlanAmount(account) * percentOfMonthAccountWasActive

ensureZeros = (accountUsageResult)->
  accountUsageResult.bandwidth ||= 0
  accountUsageResult.storage ||= 0
  accountUsageResult.peerMilliseconds ||= 0

# returns
#  plan: Number in cents
module.exports = (account, monthToBill, callback)->
  if _.all _.values(account.productPlans), _.isEmpty
    return callback null,
      billing:
        plan: 0
        prorated: false
      usage:
        bandwidth: 0
        storage: 0
        peerMilliseconds: 0
  calculateAccountUsage.byMonth account, monthToBill, (err, accountUsageResult)->
    return callback(err) if err
    ensureZeros(accountUsageResult)
    debug("Calculated", accountUsageResult)
    prorate = shouldProrateNewAccounts(account, monthToBill, accountUsageResult)
    planBill = if prorate then proratedAccountPlanAmount(account, accountUsageResult) else accountPlanAmount(account)
    result =
      billing:
        plan: planBill
        prorated: prorate
      usage:
        bandwidth: accountUsageResult.bandwidth
        storage: accountUsageResult.storage
        peerMilliseconds: accountUsageResult.peerMilliseconds
    callback(null, result)

module.exports.accountPlanAmount = accountPlanAmount
