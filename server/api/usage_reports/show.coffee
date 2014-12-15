CalculateAccountBandwidth = Cine.server_lib('reporting/broadcast/calculate_account_bandwidth')
CalculateAccountStorage = Cine.server_lib('reporting/storage/calculate_account_storage')
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

module.exports = (params, callback)->
  getAccount params, (err, account, options)->
    return callback(err, account, options) if err

    asyncCalls =
      bandwidth: (cb)->
        async.parallel createAsyncCallsForLastThreeMonthsOfBandwidth(account), cb
      storage: (cb)->
        CalculateAccountStorage.total account, cb

    async.parallel asyncCalls, (err, result)->
      return callback(err, null, status: 400) if err
      response =
        masterKey: account.masterKey
        bandwidth: result.bandwidth
        storage: result.storage
      callback(null, response)
