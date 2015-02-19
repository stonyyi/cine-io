debug = require('debug')('cine:calculate_account_usage')
async = require('async')
CalculateAccountBandwidth = Cine.server_lib('reporting/broadcast/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/storage/calculate_account_storage')
CalcualteAccountPeerMilliseconds = Cine.server_lib('reporting/peer/calculate_account_peer_milliseconds')

exports.thisMonth = (account, callback)->
  exports.byMonth account, new Date, callback

exports.byMonth = (account, month, callback)->
  asyncCalls =
    bandwidth: (cb)->
      CalculateAccountBandwidth.byMonth account, month, cb
    storage: (cb)->
      CalculateAccountStorage.byMonth account, month, cb
    peerMilliseconds: (cb)->
      CalcualteAccountPeerMilliseconds.byMonth account, month, cb

  async.parallel asyncCalls, callback

exports.byMonthWithKeenMilliseconds = (account, month, projectIdToPeerMilliseconds, callback)->
  debug("calculating account byMonthWithKeenMilliseconds", account._id, month)
  asyncCalls =
    bandwidth: (cb)->
      CalculateAccountBandwidth.byMonth account, month, cb
    storage: (cb)->
      CalculateAccountStorage.byMonth account, month, cb
    peerMilliseconds: (cb)->
      CalcualteAccountPeerMilliseconds.byMonthWithKeenMilliseconds account, month, projectIdToPeerMilliseconds, cb

  async.parallel asyncCalls, (err, results)->
    debug("calculated account byMonthWithKeenMilliseconds", account._id, month)
    callback(err, results)
