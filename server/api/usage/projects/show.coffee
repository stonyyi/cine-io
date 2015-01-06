CalculateProjectBandwidth = Cine.server_lib('reporting/broadcast/calculate_project_bandwidth')
CalculateProjectStorage = Cine.server_lib('reporting/storage/calculate_project_storage')

getProject = Cine.server_lib('get_project')
async = require('async')

module.exports = (params, callback)->
  getProject params, requires: 'secret', userOverride: true, (err, project, status)->
    return callback(err, project, status) if err
    return callback("month parameter required", null, status: 400) unless params.month
    month = params.month
    month = new Date(params.month)
    return callback("invalid month, please use ISO 8601 (http://en.wikipedia.org/wiki/ISO_8601)", null, status: 400) if isNaN(month.getTime())

    asyncCalls =
      bandwidth: (cb)->
        CalculateProjectBandwidth.byMonth project, month, cb
      storage: (cb)->
        CalculateProjectStorage.byMonth project, month, cb

    async.parallel asyncCalls, (err, result)->
      return callback(err, null, status: 400) if err
      response =
        secretKey: project.secretKey
        bandwidth: result.bandwidth
        storage: result.storage
        month: month.toISOString()
      callback(null, response)
