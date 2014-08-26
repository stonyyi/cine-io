Base = Cine.model('base')
isServer = typeof window is 'undefined'
humanizeBytes = Cine.lib('humanize_bytes')
_ = require('underscore')
ProvidersAndPlans = Cine.require('config/providers_and_plans')

maxUsagePerPlan = (provider, plan)->
  ProvidersAndPlans[provider].plans[plan].transfer

usagePerPlanAggregator = (provider)->
  return (accum, plan)->
    accum + maxUsagePerPlan(provider, plan)

module.exports = class UsageReport extends Base
  @id: 'UsageReport'
  idAttribute: 'masterKey'
  url: if isServer then "/usage-report?masterKey=:masterKey" else "/usage-report"

  @maxUsagePerAccount: (account)->
    _.inject account.get('plans'), usagePerPlanAggregator(account.get('provider')), 0

  @lowestPlanPerUsage: (bytes, includeStarter=false)->
    switch
      when includeStarter && bytes <= humanizeBytes.GiB then 'starter'
      when bytes <= humanizeBytes.GiB * 20 then 'solo'
      when bytes <= humanizeBytes.GiB * 150 then 'basic'
      else 'pro'

  @pricePerMonth: (plan)->


  @lastThreeMonths: ->
    thisMonth = new Date
    lastMonth = new Date
    lastMonth.setMonth(lastMonth.getMonth() - 1)
    twoMonthsAgo = new Date
    twoMonthsAgo.setMonth(twoMonthsAgo.getMonth() - 2)
    insertFormatToMonth = (date)->
      format = "#{date.getFullYear()}-#{date.getMonth()}"
      {date: date, format: format}

    _.map [thisMonth, lastMonth, twoMonthsAgo], insertFormatToMonth
