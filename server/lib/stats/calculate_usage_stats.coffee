require "mongoose-querystream-worker"
async = require('async')
Account = Cine.server_model('account')
CalculateAccountBandwidth = Cine.server_lib('reporting/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/calculate_account_storage')

exports.thisMonth = (done)->
  exports.byMonth new Date, done

exports.byMonth = (month, done)->
  collectiveStats = {}


  calculateUsageForAccount = (account, callback)->
    asyncCalls =
      bandwidth: (cb)->
        CalculateAccountBandwidth.byMonth account, month, cb
      storage: (cb)->
        CalculateAccountStorage.total account, cb

    async.parallel asyncCalls, (err, result)->
      return callback(err) if err
      return callback() if result.bandwidth == 0 && result.storage == 0

      collectiveStats[account._id.toString()] = result
      callback()

  endFunction = (err)->
    done(err, collectiveStats)

  scope = Account.find().where(deletedAt: {$exists: false})
  scope.stream().concurrency(20).work calculateUsageForAccount, endFunction
