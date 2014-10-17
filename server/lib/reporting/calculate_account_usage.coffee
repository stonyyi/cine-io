async = require('async')
CalculateAccountBandwidth = Cine.server_lib('reporting/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/calculate_account_storage')

exports.thisMonth = (account, callback)->
  exports.byMonth account, new Date, callback

exports.byMonth = (account, month, callback)->
  asyncCalls =
    bandwidth: (cb)->
      CalculateAccountBandwidth.byMonth account, month, cb
    storage: (cb)->
      CalculateAccountStorage.byMonth account, month, cb

  async.parallel asyncCalls, callback
