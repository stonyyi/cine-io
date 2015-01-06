CalculateAccountBandwidth = Cine.server_lib('reporting/broadcast/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/storage/calculate_account_storage')
CalcualteAccountPeerMilliseconds = Cine.server_lib('reporting/peer/calculate_account_peer_milliseconds')

getAccount = Cine.server_lib('get_account')
async = require('async')
_ = require('underscore')
UsageReport = Cine.model('usage_report')

# returns: {"2014-9": functionToCalculateThatMonthOfBandwidth(cb), …}
createAsyncCallsForLastThreeMonthsOfBandwidth = (account)->
  lastThreeMonths = UsageReport.lastThreeMonths()
  createAysncCaller = (accum, date)->
    accum[date.format] = (cb)->
      CalculateAccountBandwidth.byMonth account, date.date, cb
    return accum

  _.inject lastThreeMonths, createAysncCaller, {}

createAsyncCallsForLastThreeMonthsOfPeer = (account)->
  lastThreeMonths = UsageReport.lastThreeMonths()
  createAysncCaller = (accum, date)->
    accum[date.format] = (cb)->
      CalcualteAccountPeerMilliseconds.byMonth account, date.date, cb
    return accum

  _.inject lastThreeMonths, createAysncCaller, {}

module.exports = (params, callback)->
  getAccount params, (err, account, options)->
    return callback(err, account, options) if err
    asyncCalls = {}
    report = params.report || []
    if _.contains(params.report, 'bandwidth')
      asyncCalls.bandwidth = (cb)->
        async.parallel createAsyncCallsForLastThreeMonthsOfBandwidth(account), cb
    if _.contains(params.report, 'peerMilliseconds')
      asyncCalls.peerMilliseconds = (cb)->
        async.parallel createAsyncCallsForLastThreeMonthsOfPeer(account), cb
    if _.contains(params.report, 'storage')
      asyncCalls.storage = (cb)->
        CalculateAccountStorage.total account, cb

    async.parallel asyncCalls, (err, result)->
      return callback(err, null, status: 400) if err
      response =
        masterKey: account.masterKey

      response.bandwidth = result.bandwidth if _.contains(params.report, 'bandwidth')
      response.storage = result.storage if _.contains(params.report, 'storage')
      response.peerMilliseconds = result.peerMilliseconds if _.contains(params.report, 'peerMilliseconds')

      callback(null, response)
