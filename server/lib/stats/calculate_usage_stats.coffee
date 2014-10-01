require "mongoose-querystream-worker"
Account = Cine.server_model('account')
CalculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')

exports.thisMonth = (done)->
  exports.byMonth new Date, done

exports.byMonth = (month, done)->
  collectiveStats = {}

  callbackFunction = (account, callback)->
    return (err, collectedBytes)->
      return callback(err) if err
      return callback() if collectedBytes == 0

      collectiveStats[account._id.toString()] = collectedBytes
      callback()

  calculateUsageForAccount = (account, callback)->
    CalculateAccountUsage.byMonth account, month, callbackFunction(account, callback)

  endFunction = (err)->
    done(err, collectiveStats)

  scope = Account.find().where(deletedAt: {$exists: false})
  scope.stream().concurrency(20).work calculateUsageForAccount, endFunction
