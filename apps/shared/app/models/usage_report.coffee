Base = Cine.model('base')
isServer = typeof window is 'undefined'
humanizeBytes = Cine.lib('humanize_bytes')

module.exports = class UsageReport extends Base
  @id: 'UsageReport'
  idAttribute: 'masterKey'
  url: if isServer then "/usage-report?masterKey=:masterKey" else "/usage-report"

  # TODO, move to actual bytes numbers
  @maxUsagePerAccount: (user)->
    switch user.get('plan')
      when 'free', 'starter', 'test' then humanizeBytes.GB
      when 'solo' then humanizeBytes.GB * 20
      when 'startup' then humanizeBytes.GB * 150
      when 'enterprise' then humanizeBytes.TB
