debug = require('debug')('cine:calculate_and_save_usage_stats')
calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Stats = Cine.server_lib("stats")

module.exports = (callback)->
  module.exports.byMonth new Date, callback

module.exports.byMonth = (month, callback)->
  debug("calculating", month)
  calculateUsageStats.byMonth month, (err, collectiveStats)->
    debug("calculated", month)
    return callback(err) if err
    Stats.setUsage month, collectiveStats, callback
