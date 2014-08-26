Base = Cine.model('base')
isServer = typeof window is 'undefined'
humanizeBytes = Cine.lib('humanize_bytes')
_ = require('underscore')

maxUsagePerPlan = (plan)->
  switch plan
    when 'free', 'starter', 'test' then humanizeBytes.GiB
    when 'solo' then humanizeBytes.GiB * 20
    when 'basic' then humanizeBytes.GiB * 150
    when 'pro' then humanizeBytes.TiB

usagePerPlanAggregator = (accum, plan)->
  accum + maxUsagePerPlan(plan)

module.exports = class UsageReport extends Base
  @id: 'UsageReport'
  idAttribute: 'masterKey'
  url: if isServer then "/usage-report?masterKey=:masterKey" else "/usage-report"

  @maxUsagePerAccount: (account)->
    _.inject account.get('plans'), usagePerPlanAggregator, 0

  @lowestPlanPerUsage: (bytes, includeStarter=false)->
    switch
      when includeStarter && bytes <= humanizeBytes.GiB then 'starter'
      when bytes <= humanizeBytes.GiB * 20 then 'solo'
      when bytes <= humanizeBytes.GiB * 150 then 'basic'
      else 'pro'

  @pricePerMonth: (plan)->
    switch plan
      when 'free', 'starter', 'test' then 0
      when 'solo' then 20
      when 'basic' then 100
      when 'pro' then 500

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
