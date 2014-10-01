calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Stats = Cine.server_lib("stats")

module.exports = (callback)->
  module.exports.byMonth new Date, calculateUsageStats

# I know this isn't ideal.
# It overwrites a global stats with a different month
module.exports.saveByMonth = (month, callback)->
  calculateUsageStats.byMonth month, (err, collectiveStats)->
    Stats.setUsage collectiveStats, callback
