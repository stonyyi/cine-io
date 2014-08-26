basicModel = Cine.require 'test/helpers/basic_model'
UsageReport = Cine.model('usage_report')
Account = Cine.model('account')
humanizeBytes = Cine.lib('humanize_bytes')
basicModel('usage_report', urlAttributes: ['masterKey'], id: 'masterKey')


describe 'UsageReport', ->
  describe 'maxUsagePerAccount', ->
    it 'returns the max amount', ->
      account = new Account(provider: 'cine.io')
      account.attributes.plans = ['free']
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(1073741824)
      account.attributes.plans = ['solo']
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(21474836480)
      account.attributes.plans = ['basic']
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(161061273600)
      account.attributes.plans = ['pro']
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(1099511627776)

    it 'works with combos', ->
      account = new Account(provider: 'cine.io')
      account.attributes.plans = ['free', 'pro']
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(1073741824 + 1099511627776)
      account.attributes.plans = ['free', 'solo', 'basic']
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(1073741824 + 21474836480 + 161061273600)

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
    it 'is tested'
