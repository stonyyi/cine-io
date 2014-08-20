Base = Cine.model('base')
isServer = typeof window is 'undefined'
humanizeBytes = Cine.lib('humanize_bytes')
_ = require('underscore')

module.exports = class UsageReport extends Base
  @id: 'UsageReport'
  idAttribute: 'masterKey'
  url: if isServer then "/usage-report?masterKey=:masterKey" else "/usage-report"

  @maxUsagePerAccount: (account)->
    switch account.get('tempPlan')
      when 'free', 'starter', 'test' then humanizeBytes.GiB
      when 'solo' then humanizeBytes.GiB * 20
      when 'startup' then humanizeBytes.GiB * 150
      when 'enterprise' then humanizeBytes.TiB

  @lowestPlanPerUsage: (bytes)->
    switch
      when bytes <= humanizeBytes.GiB then 'starter'
      when bytes <= humanizeBytes.GiB * 20 then 'solo'
      when bytes <= humanizeBytes.GiB * 150 then 'startup'
      else 'enterprise'

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
