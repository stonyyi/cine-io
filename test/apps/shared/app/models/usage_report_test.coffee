basicModel = Cine.require 'test/helpers/basic_model'
UsageReport = Cine.model('usage_report')
Account = Cine.model('account')
humanizeBytes = Cine.lib('humanize_bytes')
basicModel('usage_report', urlAttributes: ['masterKey'], id: 'masterKey')


describe 'UsageReport', ->
  describe 'maxUsagePerAccount', ->
    it 'returns the max amount', ->
      account = new Account()
      account.attributes.tempPlan = 'free'
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(1073741824)
      account.attributes.tempPlan = 'solo'
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(21474836480)
      account.attributes.tempPlan = 'basic'
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(161061273600)
      account.attributes.tempPlan = 'pro'
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(1099511627776)

  describe 'lowestPlanPerUsage', ->
    it 'returns the lowest plan', ->
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.MiB * 10)).to.equal('starter')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB - 100)).to.equal('starter')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB + 100)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB * 20 - 100)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GiB * 150 - 100)).to.equal('basic')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TiB - 100)).to.equal('pro')

  describe 'lastThreeMonths', ->
    it 'is tested'
