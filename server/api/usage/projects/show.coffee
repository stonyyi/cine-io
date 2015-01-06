_ = require('underscore')
async = require('async')
CalculateProjectBandwidth = Cine.server_lib('reporting/broadcast/calculate_project_bandwidth')
CalculateProjectStorage = Cine.server_lib('reporting/storage/calculate_project_storage')

getProject = Cine.server_lib('get_project')

module.exports = (params, callback)->
  getProject params, requires: 'secret', userOverride: true, (err, project, status)->
    return callback(err, project, status) if err
    return callback("month parameter required", null, status: 400) unless params.month
    month = params.month
    month = new Date(params.month)
    return callback("invalid month, please use ISO 8601 (http://en.wikipedia.org/wiki/ISO_8601)", null, status: 400) if isNaN(month.getTime())

    asyncCalls = {}
    report = params.report || []

    if _.contains(params.report, 'bandwidth')
      asyncCalls.bandwidth = (cb)->
        CalculateProjectBandwidth.byMonth project, month, cb

    if _.contains(params.report, 'storage')
      asyncCalls.storage = (cb)->
        CalculateProjectStorage.byMonth project, month, cb

    async.parallel asyncCalls, (err, result)->
      return callback(err, null, status: 400) if err
      response =
        secretKey: project.secretKey
        month: month.toISOString()
      response.bandwidth = result.bandwidth if result.bandwidth
      response.storage = result.storage if result.storage
      callback(null, response)
