_ = require('underscore')
moment = require('moment')

User = Cine.server_model('user')
Account = Cine.server_model('account')
Stats = Cine.server_lib("stats")

ensureSiteAdmin = (params, callback)->
  return callback(false) unless params.sessionUserId
  User.findById params.sessionUserId, (err, user)->
    return callback(false) if err || !user
    return callback(user.isSiteAdmin)

ensureSiteAdmin.unauthorizedCallback = (callback)->
  callback("Unauthorized", null, status: 401)

# changes {accountId: dataInBytes, …}
# to [_id: accountId, usage: dataInBytes, name: "Account name", …]
accountFromAccountId = (accounts, accountId)->
  _.find accounts, (account)->
    account._id.toString() == accountId.toString()

updateUsageWithAccountInformation = (results, callback)->
  accountIds = _.keys(results)
  Account.where(_id: {$in: accountIds}).exec (err, accounts)->
    return callback(err) if err
    resultToExpectedOutput = (accum, dataInBytes, accountId)->
      account = accountFromAccountId(accounts, accountId)
      return unless account
      result = account.toJSON()
      result.usage = dataInBytes
      accum.push result
      accum
    response = _.inject results, resultToExpectedOutput, []
    callback(null, response)

module.exports = (params, callback)->
  ensureSiteAdmin params, (isSiteAdmin)->
    return ensureSiteAdmin.unauthorizedCallback(callback) unless isSiteAdmin

    Stats.getAll (err, results)->
      return callback(err) if err
      return callback("results not found") unless results
      #hack: the stats are always for the current month
      # but we might want to be able to choose a month later
      results.usageMonth = new Date
      results.usageMonthName = moment(results.usageMonth).format("MMM YYYY")
      updateUsageWithAccountInformation results.usage, (err, usage)->
        results.usage = usage
        return callback(err, null) if err
        callback(null, _.extend(id: params.id, results))
