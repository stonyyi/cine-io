debug = require('debug')('cine:calculate_usage_stats')
require "mongoose-querystream-worker"
Account = Cine.server_model('account')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
fetchAllProjectsPeerMilliseconds = Cine.server_lib('reporting/peer/fetch_all_projects_peer_milliseconds')
checkKeenStatus = Cine.server_lib('reporting/check_keen_io_status')
exports.thisMonth = (done)->
  exports.byMonth new Date, done

exports.byMonth = (month, done)->
  checkKeenStatus (err)->
    return done(err) if err
    collectiveStats = {}
    debug("fetching keen peer milliseconds")
    fetchAllProjectsPeerMilliseconds.byMonth month, (err, projectIdToPeerMilliseconds)->
      debug("fetched keen peer milliseconds", err)
      return done(err) if err
      calculateUsageForAccount = (account, callback)->
        calculateAccountUsage.byMonthWithKeenMilliseconds account, month, projectIdToPeerMilliseconds, (err, result)->
          return callback(err) if err
          return callback() if result.bandwidth == 0 && result.storage == 0 && result.peerMilliseconds == 0

          collectiveStats[account._id.toString()] = result
          callback()

      endFunction = (err)->
        debug("done processing all accounts", err)
        done(err, collectiveStats)

      scope = Account.find().where(deletedAt: {$exists: false})
      scope.stream().concurrency(20).work calculateUsageForAccount, endFunction

