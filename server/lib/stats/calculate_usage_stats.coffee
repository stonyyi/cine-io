require "mongoose-querystream-worker"
Account = Cine.server_model('account')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
fetchAllProjectsPeerMilliseconds = Cine.server_lib('reporting/peer/fetch_all_projects_peer_milliseconds')

exports.thisMonth = (done)->
  exports.byMonth new Date, done

exports.byMonth = (month, done)->
  collectiveStats = {}
  fetchAllProjectsPeerMilliseconds month, (err, projectIdToPeerMilliseconds)->

    calculateUsageForAccount = (account, callback)->
      calculateAccountUsage.byMonth account, month, (err, result)->
        return callback(err) if err
        return callback() if result.bandwidth == 0 && result.storage == 0 && result.peerMilliseconds == 0

        collectiveStats[account._id.toString()] = result
        callback()

    endFunction = (err)->
      done(err, collectiveStats)

    scope = Account.find().where(deletedAt: {$exists: false})
    scope.stream().concurrency(20).work calculateUsageForAccount, endFunction

