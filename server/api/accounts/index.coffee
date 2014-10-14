async = require('async')
ensureSiteAdmin = Cine.server_lib('ensure_site_admin_for_api')
fullCurrentUserJson = Cine.server_lib('full_current_user_json')
Account = Cine.server_model('account')

accountJson = (account, callback)->
  fullCurrentUserJson.accountJson account, (err, json)->
    return callback(err, json) if err
    json.throttledAt = account.throttledAt
    callback(null, json)

module.exports = (params, callback)->
  ensureSiteAdmin params, (isSiteAdmin)->
    return ensureSiteAdmin.unauthorizedCallback(callback) unless isSiteAdmin

    if params.throttled
      Account.find().exists('throttledAt', true).sort(throttledAt: 'desc').exec (err, accounts)->
        return callback(err, null, status: 400) if err
        async.map accounts, accountJson, (err, accountsJson)->
          return callback(err, null, status: 400) if err
          callback(null, accountsJson)

    else
      callback("don't know how to respond", null, status: 400)
