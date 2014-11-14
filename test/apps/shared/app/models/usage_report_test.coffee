_ = require('underscore')
basicModel = Cine.require 'test/helpers/basic_model'
UsageReport = Cine.model('usage_report')
Account = Cine.model('account')
humanizeBytes = Cine.lib('humanize_bytes')
ProvidersAndPlans = Cine.config('providers_and_plans')

basicModel('usage_report', urlAttributes: ['masterKey'], id: 'masterKey')


describe 'UsageReport', ->
  describe 'maxUsagePerAccount', ->
    describe 'bandwidth', ->
      it 'returns the max amount', ->
        account = new Account(provider: 'cine.io')
        account.attributes.plans = ['free']
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth')).to.equal(1073741824)
        account.attributes.plans = ['solo']
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth')).to.equal(21474836480)
        account.attributes.plans = ['basic']
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth')).to.equal(161061273600)
        account.attributes.plans = ['pro']
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth')).to.equal(1099511627776)

      it 'works with combos', ->
        account = new Account(provider: 'cine.io')
        account.attributes.plans = ['free', 'pro']
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth')).to.equal(1073741824 + 1099511627776)
        account.attributes.plans = ['free', 'solo', 'basic']
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth')).to.equal(1073741824 + 21474836480 + 161061273600)

    describe 'storage', ->
      it 'returns the max amount', ->
        account = new Account(provider: 'cine.io')
        account.attributes.plans = ['free']
        expect(UsageReport.maxUsagePerAccount(account, 'storage')).to.equal(0)
        account.attributes.plans = ['solo']
        expect(UsageReport.maxUsagePerAccount(account, 'storage')).to.equal(5368709120)
        account.attributes.plans = ['basic']
        expect(UsageReport.maxUsagePerAccount(account, 'storage')).to.equal(26843545600)
        account.attributes.plans = ['pro']
        expect(UsageReport.maxUsagePerAccount(account, 'storage')).to.equal(107374182400)

      it 'works with combos', ->
        account = new Account(provider: 'cine.io')
        account.attributes.plans = ['free', 'pro']
        expect(UsageReport.maxUsagePerAccount(account, 'storage')).to.equal(0 + 107374182400)
        account.attributes.plans = ['free', 'solo', 'basic']
        expect(UsageReport.maxUsagePerAccount(account, 'storage')).to.equal(0 + 5368709120 + 26843545600)

  describe '.lowestPlanPerUsage', ->
    it 'returns the lowest plan', ->
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.MiB * 10)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB - 100)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB + 100)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB * 20 - 100)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB * 150 - 100)).to.equal('basic')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB * 500 - 100)).to.equal('premium')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TiB - 100)).to.equal('pro')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TiB * 2 - 100)).to.equal('startup')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TiB * 5 - 100)).to.equal('business')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TiB * 5 + 100)).to.equal('enterprise')

    it 'returns the lowest plan with allowing for free', ->
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.MiB * 10, true)).to.equal('free')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB - 100, true)).to.equal('free')

  describe '.sortedCinePlans', ->
    it 'includes the cine plans', ->
      plans = UsageReport.sortedCinePlans()
      expect(plans).to.have.length(_.pairs(ProvidersAndPlans['cine.io'].plans).length)

    it 'sorts the plans based on order', ->
      plans = UsageReport.sortedCinePlans()
      expect(plans[0].name).to.equal('free')
      expect(plans[0].price).to.equal(0)
      expect(plans[7].name).to.equal('enterprise')
      expect(plans[7].price).to.equal(5000)

  describe '.lastThreeMonths', ->
    beforeEach ->
      @thisMonth = new Date
      @lastMonth = new Date
      @lastMonth.setDate(1)
      @lastMonth.setMonth(@lastMonth.getMonth() - 1)
      @twoMonthsAgo = new Date
      @twoMonthsAgo.setDate(1)
      @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

    it 'is tested', ->
      actual = UsageReport.lastThreeMonths()
      expect(actual[0].format).to.equal("#{@thisMonth.getFullYear()}-#{@thisMonth.getMonth()}")
      expect(actual[0].date.getMonth()).to.equal(@thisMonth.getMonth())
      expect(actual[0].date.getFullYear()).to.equal(@thisMonth.getFullYear())

      expect(actual[1].format).to.equal("#{@lastMonth.getFullYear()}-#{@lastMonth.getMonth()}")
      expect(actual[1].date.getMonth()).to.equal(@lastMonth.getMonth())
      expect(actual[1].date.getFullYear()).to.equal(@lastMonth.getFullYear())

      expect(actual[2].format).to.equal("#{@twoMonthsAgo.getFullYear()}-#{@twoMonthsAgo.getMonth()}")
      expect(actual[2].date.getMonth()).to.equal(@twoMonthsAgo.getMonth())
      expect(actual[2].date.getFullYear()).to.equal(@twoMonthsAgo.getFullYear())
