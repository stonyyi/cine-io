CalculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
getUser = Cine.server_lib('get_user')

module.exports = (params, callback)->
  getUser params, (err, user, options)->
    return callback(err, user, options) if err
    d = new Date
    CalculateAccountUsage.byMonth user, d, (err, monthlyBytes)->
      return callback(err, null, status: 400) if err
      callback(null, masterKey: user.masterKey, monthlyBytes: monthlyBytes)
