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
      account.attributes.tempPlan = 'startup'
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(161061273600)
      account.attributes.tempPlan = 'enterprise'
      expect(UsageReport.maxUsagePerAccount(account)).to.equal(1099511627776)

  describe 'lowestPlanPerUsage', ->
    it 'returns the lowest plan', ->
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.MB * 10)).to.equal('starter')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GB - 100)).to.equal('starter')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GB + 100)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GB * 20 - 100)).to.equal('solo')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.GB * 150 - 100)).to.equal('startup')
      expect(UsageReport.lowestPlanPerUsage(humanizeBytes.TB - 100)).to.equal('enterprise')

  describe 'lastThreeMonths', ->
    it 'is tested'
