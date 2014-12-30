_ = require('underscore')
basicModel = Cine.require 'test/helpers/basic_model'
UsageReport = Cine.model('usage_report')
Account = Cine.model('account')
humanizeBytes = Cine.lib('humanize_bytes')
ProvidersAndPlans = Cine.config('providers_and_plans')

basicModel('usage_report', urlAttributes: ['masterKey'], id: 'masterKey')

THOUSAND = 1000
MINUTES = 60 * 1000

describe 'UsageReport', ->
  describe 'maxUsagePerAccount', ->
    describe 'bandwidth', ->
      it 'returns the max amount', ->
        account = new Account(provider: 'cine.io')
        account.attributes.productPlans = {broadcast: ['free']}
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth', 'broadcast')).to.equal(1073741824)
        account.attributes.productPlans = {broadcast: ['solo']}
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth', 'broadcast')).to.equal(21474836480)
        account.attributes.productPlans = {broadcast: ['basic']}
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth', 'broadcast')).to.equal(161061273600)
        account.attributes.productPlans = {broadcast: ['pro']}
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth', 'broadcast')).to.equal(1099511627776)

      it 'works with empty', ->
        account = new Account(provider: 'cine.io')
        account.attributes.productPlans = {}
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth', 'broadcast')).to.equal(0)
        account.attributes.productPlans = {broadcast: []}
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth', 'broadcast')).to.equal(0)

      it 'works with combos', ->
        account = new Account(provider: 'cine.io')
        account.attributes.productPlans = {broadcast: ['free', 'pro']}
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth', 'broadcast')).to.equal(1073741824 + 1099511627776)
        account.attributes.productPlans = {broadcast: ['free', 'solo', 'basic']}
        expect(UsageReport.maxUsagePerAccount(account, 'bandwidth', 'broadcast')).to.equal(1073741824 + 21474836480 + 161061273600)

    describe 'storage', ->
      it 'returns the max amount', ->
        account = new Account(provider: 'cine.io')
        account.attributes.productPlans = {broadcast: ['free']}
        expect(UsageReport.maxUsagePerAccount(account, 'storage', 'broadcast')).to.equal(0)
        account.attributes.productPlans = {broadcast: ['solo']}
        expect(UsageReport.maxUsagePerAccount(account, 'storage', 'broadcast')).to.equal(5368709120)
        account.attributes.productPlans = {broadcast: ['basic']}
        expect(UsageReport.maxUsagePerAccount(account, 'storage', 'broadcast')).to.equal(26843545600)
        account.attributes.productPlans = {broadcast: ['pro']}
        expect(UsageReport.maxUsagePerAccount(account, 'storage', 'broadcast')).to.equal(107374182400)

      it 'works with empty', ->
        account = new Account(provider: 'cine.io')
        account.attributes.productPlans = {}
        expect(UsageReport.maxUsagePerAccount(account, 'storage', 'broadcast')).to.equal(0)
        account.attributes.productPlans = {broadcast: []}
        expect(UsageReport.maxUsagePerAccount(account, 'storage', 'broadcast')).to.equal(0)

      it 'works with combos', ->
        account = new Account(provider: 'cine.io')
        account.attributes.productPlans = {broadcast: ['free', 'pro']}
        expect(UsageReport.maxUsagePerAccount(account, 'storage', 'broadcast')).to.equal(0 + 107374182400)
        account.attributes.productPlans = {broadcast: ['free', 'solo', 'basic']}
        expect(UsageReport.maxUsagePerAccount(account, 'storage', 'broadcast')).to.equal(0 + 5368709120 + 26843545600)

    describe 'peer', ->
      it 'returns the max amount', ->
        account = new Account(provider: 'cine.io')
        account.attributes.productPlans = {peer: ['free']}
        expect(UsageReport.maxUsagePerAccount(account, 'minutes', 'peer')).to.equal(60 * MINUTES)
        account.attributes.productPlans = {peer: ['solo']}
        expect(UsageReport.maxUsagePerAccount(account, 'minutes', 'peer')).to.equal(2 * THOUSAND * MINUTES)
        account.attributes.productPlans = {peer: ['basic']}
        expect(UsageReport.maxUsagePerAccount(account, 'minutes', 'peer')).to.equal(12.5 * THOUSAND * MINUTES)
        account.attributes.productPlans = {peer: ['pro']}
        expect(UsageReport.maxUsagePerAccount(account, 'minutes', 'peer')).to.equal(70 * THOUSAND * MINUTES)

      it 'works with empty', ->
        account = new Account(provider: 'cine.io')
        account.attributes.productPlans = {}
        expect(UsageReport.maxUsagePerAccount(account, 'minutes', 'peer')).to.equal(0)
        account.attributes.productPlans = {peer: []}
        expect(UsageReport.maxUsagePerAccount(account, 'minutes', 'peer')).to.equal(0)

      it 'works with combos', ->
        account = new Account(provider: 'cine.io')
        account.attributes.productPlans = {peer: ['free', 'pro']}
        expect(UsageReport.maxUsagePerAccount(account, 'minutes', 'peer')).to.equal(60 * MINUTES + 70 * THOUSAND * MINUTES)
        account.attributes.productPlans = {peer: ['free', 'solo', 'basic']}
        expect(UsageReport.maxUsagePerAccount(account, 'minutes', 'peer')).to.equal(60 * MINUTES + 2 * THOUSAND * MINUTES + 12.5 * THOUSAND * MINUTES)

      it 'works with other accounts', ->
        account = new Account(provider: 'heroku')
        account.attributes.productPlans = {}
        expect(UsageReport.maxUsagePerAccount(account, 'minutes', 'peer')).to.equal(0)
        account.attributes.productPlans = {peer: []}
        expect(UsageReport.maxUsagePerAccount(account, 'minutes', 'peer')).to.equal(0)

  describe '.lowestPlanPerUsage', ->
    it 'returns the lowest plan', ->
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.MiB * 10, 'bandwidth', 'broadcast')).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB - 100, 'bandwidth', 'broadcast')).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB + 100, 'bandwidth', 'broadcast')).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB * 20 - 100, 'bandwidth', 'broadcast')).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB * 150 - 100, 'bandwidth', 'broadcast')).to.equal('basic')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB * 500 - 100, 'bandwidth', 'broadcast')).to.equal('premium')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TiB - 100, 'bandwidth', 'broadcast')).to.equal('pro')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TiB * 2 - 100, 'bandwidth', 'broadcast')).to.equal('startup')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TiB * 5 - 100, 'bandwidth', 'broadcast')).to.equal('business')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TiB * 5 + 100, 'bandwidth', 'broadcast')).to.equal('enterprise')

    it 'returns the lowest plan with allowing for free', ->
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.MiB * 10, 'bandwidth', 'broadcast', true)).to.equal('free')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB - 100, 'bandwidth', 'broadcast', true)).to.equal('free')

  describe '.sortedCinePlans', ->
    it 'includes the cine plans', ->
      plans = UsageReport.sortedCinePlans('broadcast')
      expect(plans).to.have.length(_.pairs(ProvidersAndPlans['cine.io'].broadcast.plans).length)

    it 'sorts the plans based on order', ->
      plans = UsageReport.sortedCinePlans('broadcast')
      expect(plans[0].name).to.equal('free')
      expect(plans[0].price).to.equal(0)
      expect(plans[7].name).to.equal('enterprise')
      expect(plans[7].price).to.equal(5000)

  describe '.nextPlan', ->
    it 'gives the next plan', ->
      account = new Account(provider: 'cine.io')
      account.attributes.productPlans = {broadcast: ['pro']}
      expect(UsageReport.nextPlan(account, 'broadcast')).to.equal('startup')
      account.attributes.productPlans = {broadcast: ['enterprise']}
      expect(UsageReport.nextPlan(account, 'broadcast')).to.equal('enterprise')

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
