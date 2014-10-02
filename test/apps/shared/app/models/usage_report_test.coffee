basicModel = Cine.require 'test/helpers/basic_model'
UsageReport = Cine.model('usage_report')
Account = Cine.model('account')
humanizeBytes = Cine.lib('humanize_bytes')
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

  describe 'lowestPlanPerUsage', ->
    it 'returns the lowest plan with allowing', ->
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.MiB * 10)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB - 100)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB + 100)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB * 20 - 100)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB * 150 - 100)).to.equal('basic')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TiB - 100)).to.equal('pro')

    it 'returns the lowest plan with allowing for starter', ->
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.MiB * 10, true)).to.equal('starter')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB - 100, true)).to.equal('starter')

  describe 'lastThreeMonths', ->
    beforeEach ->
      @thisMonth = new Date
      @lastMonth = new Date
      @lastMonth.setMonth(@lastMonth.getMonth() - 1)
      @twoMonthsAgo = new Date
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
