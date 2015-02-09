calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Stats = Cine.server_lib("stats")

module.exports = (callback)->
  module.exports.byMonth new Date, callback

module.exports.byMonth = (month, callback)->
  calculateUsageStats.byMonth month, (err, collectiveStats)->
    return callback(err) if err
    Stats.setUsage month, collectiveStats, callback
