Base = Cine.model('base')
humanizeBytes = Cine.lib('humanize_bytes')
_ = require('underscore')
ProvidersAndPlans = Cine.require('config/providers_and_plans')

maxUsagePerPlan = (provider, product, plan, type)->
  ProvidersAndPlans[provider][product].plans[plan][type]

usagePerPlanAggregator = (provider, product, type)->
  return (accum, plan)->
    accum + maxUsagePerPlan(provider, product, plan, type)

module.exports = class UsageReport extends Base
  @id: 'UsageReport'
  idAttribute: 'masterKey'
  url: ->
    switch @get('scope')
      when 'account'
        "/usage/account?masterKey=:masterKey"
      when 'project'
        "/usage/project?secretKey=:secretKey"
      when 'stream'
        "/usage/stream?id=:id&secretKey=:secretKey"
      else
        throw new Error("Unknown scope")

  # type: bandwidth/storage
  @maxUsagePerAccount: (account, type, product)->
    plans = switch product
      when 'broadcast'
        account.broadcastPlans()
      when 'peer'
        account.peerPlans()
      else
        throw new Error("unknown plans")
    _.inject plans, usagePerPlanAggregator(account.get('provider'), product, type), 0

  # product is either broadcast or peer
  @sortedCinePlans: (product)->
    planOptions = _.chain(ProvidersAndPlans['cine.io'][product].plans).pairs().filter((planNameDetails)-> planNameDetails[1].order ).value()
    mappedPlans = _.map planOptions, (nameValue)->
      nameValue[1].name = nameValue[0]
      nameValue[1]
    cinePlans = _.sortBy mappedPlans, "order"

  @lowestPlanPerUsage: (bytes, type, product, includeStarter=false)->
    cinePlans = @sortedCinePlans(product)
    thing = _.find cinePlans, (planDetails)->
      return false if planDetails.price == 0 && !includeStarter
      planDetails[type] >= bytes
    thing ||= _.last(cinePlans)
    return thing.name

  @nextPlan: (account, product)->
    foundAccountPlan = false
    cinePlans = @sortedCinePlans(product)
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
