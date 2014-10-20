calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Stats = Cine.server_lib("stats")

calculateAndSaveUsageStats = module.exports

calculateAndSaveUsageStats.thisMonth = (callback)->
  calculateAndSaveUsageStats.byMonth new Date, callback

calculateAndSaveUsageStats.byMonth = (month, callback)->
  calculateUsageStats.byMonth month, (err, collectiveStats)->
    Stats.setUsage month, collectiveStats, callback
