_ = require('underscore')
moment = require('moment')
async = require('async')
Account = Cine.server_model('account')
Stats = Cine.server_lib("stats")
ensureSiteAdmin = Cine.server_lib('ensure_site_admin_for_api')
fullCurrentUserJSON = Cine.server_lib('full_current_user_json')
# changes {accountId: dataInBytes, …}
# to [_id: accountId, usage: dataInBytes, name: "Account name", …]
accountFromAccountId = (accounts, accountId)->
  _.find accounts, (account)->
    account._id.toString() == accountId.toString()

updateUsageWithAccountInformation = (results, callback)->
  # console.log("got results", results)
  pairs = _.pairs(results)
  findAccountsForStats = (monthlyAccum, tuple, cb)->
    key = tuple[0]
    monthlyResults = tuple[1]
    accountIds = _.keys(monthlyResults)
    Account.where(_id: {$in: accountIds}).exec (err, accounts)->
      return cb(err) if err
      resultToExpectedOutput = (accum, data, cb2)->
        accountId = data[0]
        dataInBytes = data[1]
        console.log("accountId", accountId)
        console.log("dataInBytes", dataInBytes)
        account = accountFromAccountId(accounts, accountId)
        return cb2("no account") unless account
        fullCurrentUserJSON.accountJson account, (err, result)->
          return cb2(err) if err
          result.usage = dataInBytes
          accum.push result
          cb2(null, accum)
      async.inject _.pairs(monthlyResults), [], resultToExpectedOutput, (err, value)->
        monthlyAccum[key] = value
        cb(null, monthlyAccum)
  async.reduce pairs, {}, findAccountsForStats, callback

module.exports = (params, callback)->
  ensureSiteAdmin params, (isSiteAdmin)->
    return ensureSiteAdmin.unauthorizedCallback(callback) unless isSiteAdmin

    Stats.getAll (err, results)->
      return callback(err) if err
      return callback("results not found") unless results
      updateUsageWithAccountInformation results, (err, usage)->
        return callback(err, null) if err
        callback(null, _.extend(id: params.id, usage: usage))
