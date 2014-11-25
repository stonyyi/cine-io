Base = Cine.model('base')
humanizeBytes = Cine.lib('humanize_bytes')
_ = require('underscore')
ProvidersAndPlans = Cine.require('config/providers_and_plans')

maxUsagePerPlan = (provider, plan, type)->
  ProvidersAndPlans[provider].plans[plan][type]

usagePerPlanAggregator = (provider, type)->
  return (accum, plan)->
    accum + maxUsagePerPlan(provider, plan, type)

module.exports = class UsageReport extends Base
  @id: 'UsageReport'
  idAttribute: 'masterKey'
  url: "/usage-report?masterKey=:masterKey"

  # type: bandwidth/storage
  @maxUsagePerAccount: (account, type)->
    _.inject account.get('plans'), usagePerPlanAggregator(account.get('provider'), type), 0

  @sortedCinePlans: ->
    planOptions = _.chain(ProvidersAndPlans['cine.io'].plans).pairs().filter((planNameDetails)-> planNameDetails[1].order ).value()
    mappedPlans = _.map planOptions, (nameValue)->
      nameValue[1].name = nameValue[0]
      nameValue[1]
    cinePlans = _.sortBy mappedPlans, "order"

  @lowestPlanPerUsage: (bytes, type, includeStarter=false)->
    cinePlans = @sortedCinePlans()
    thing = _.find cinePlans, (planDetails)->
      return false if planDetails.price == 0 && !includeStarter
      planDetails[type] >= bytes
    thing ||= _.last(cinePlans)
    return thing.name

  @nextPlan: (account)->
    foundAccountPlan = false
    cinePlans = @sortedCinePlans()
    thing = _.find cinePlans, (planDetails)->
      if planDetails.name == account.firstPlan()
        foundAccountPlan = true
        return false
      return foundAccountPlan
    thing ||= _.last(cinePlans)
    return thing.name

  @lastThreeMonths: ->
    thisMonth = new Date
    lastMonth = new Date
    lastMonth.setDate(1)
    lastMonth.setMonth(lastMonth.getMonth() - 1)
    twoMonthsAgo = new Date
    twoMonthsAgo.setDate(1)
    twoMonthsAgo.setMonth(twoMonthsAgo.getMonth() - 2)
    insertFormatToMonth = (date)->
      format = "#{date.getFullYear()}-#{date.getMonth()}"
      {date: date, format: format}

    _.map [thisMonth, lastMonth, twoMonthsAgo], insertFormatToMonth
