_ = require('underscore')
async = require('async')

EdgecastStream = Cine.server_model('edgecast_stream')
StreamUsageReport = Cine.server_model('stream_usage_report')
StreamRecordings = Cine.server_model('stream_recordings')

getProject = Cine.server_lib('get_project')

module.exports = (params, callback)->
  getProject params, requires: 'secret', userOverride: true, (err, project, status)->
    return callback(err, project, status) if err
    return callback("id parameter required", null, status: 400) unless params.id
    return callback("month parameter required", null, status: 400) unless params.month
    month = params.month
    month = new Date(params.month)
    return callback("invalid month, please use ISO 8601 (http://en.wikipedia.org/wiki/ISO_8601)", null, status: 400) if isNaN(month.getTime())

    # verify stream exists in project
    query =
      _id: params.id
      _project: project._id
    # console.log("Finding stream", query)
    EdgecastStream.findOne query, (err, stream)->
      return callback(err, null, status) if err
      return callback("stream not found", null, status: 404) unless stream

      asyncCalls = {}
      if _.contains(params.report, 'bandwidth')
        asyncCalls.bandwidth = (cb)->
          StreamUsageReport.findOne _edgecastStream: params.id, (err, streamUsageReport)->
            return cb(err) if err
            cb null, streamUsageReport.bytesForMonth(month)
      if _.contains(params.report, 'storage')
        asyncCalls.storage = (cb)->
          StreamRecordings.findOne _edgecastStream: params.id, (err, streamRecordings)->
            return cb(err) if err
            cb null, streamRecordings.bytesForMonth(month)

      async.parallel asyncCalls, (err, result)->
        return callback(err, null, status: 400) if err
        response =
          secretKey: project.secretKey
          id: stream._id.toString()
          month: month.toISOString()
        response.bandwidth = result.bandwidth if _.contains(params.report, 'bandwidth')
        response.storage = result.storage if _.contains(params.report, 'storage')
        callback(null, response)
