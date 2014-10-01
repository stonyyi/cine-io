calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Stats = Cine.server_lib("stats")

module.exports = (callback)->
  calculateUsageStats.thisMonth (err, collectiveStats)->
    Stats.setUsage collectiveStats, callback
