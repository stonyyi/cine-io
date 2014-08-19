CalculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
getAccount = Cine.server_lib('get_account')
async = require('async')
_ = require('underscore')
UsageReport = Cine.model('usage_report')

module.exports = (params, callback)->
  getAccount params, (err, account, options)->
    return callback(err, account, options) if err
    lastThreeMonths = UsageReport.lastThreeMonths()
    createAysncCaller = (accum, date)->
      accum[date.format] = (callback)->
        CalculateAccountUsage.byMonth account, date.date, callback
      return accum

    asyncCalls = _.inject lastThreeMonths, createAysncCaller, {}
    async.parallel asyncCalls, (err, result)->
      return callback(err, null, status: 400) if err
      result.masterKey = account.masterKey
      callback(null, result)
