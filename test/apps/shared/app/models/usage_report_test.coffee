basicModel = Cine.require 'test/helpers/basic_model'
UsageReport = Cine.model('usage_report')
User = Cine.model('user')
humanizeBytes = Cine.lib('humanize_bytes')
basicModel('usage_report', urlAttributes: ['masterKey'], id: 'masterKey')


describe 'UsageReport', ->
  describe 'maxUsagePerAccount', ->
    it 'returns the max amount', ->
      u = new User()
      u.attributes.plan = 'free'
      expect(UsageReport.maxUsagePerAccount(u)).to.equal(1073741824)
      u.attributes.plan = 'solo'
      expect(UsageReport.maxUsagePerAccount(u)).to.equal(21474836480)
      u.attributes.plan = 'startup'
      expect(UsageReport.maxUsagePerAccount(u)).to.equal(161061273600)
      u.attributes.plan = 'enterprise'
      expect(UsageReport.maxUsagePerAccount(u)).to.equal(1099511627776)

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
