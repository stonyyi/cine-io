calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Stats = Cine.server_lib("stats")

module.exports = (month, callback)->
  calculateUsageStats.byMonth month, (err, collectiveStats)->
    Stats.setUsage month, collectiveStats, callback
