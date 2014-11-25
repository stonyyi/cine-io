EdgecastStream = Cine.server_model('edgecast_stream')
StreamUsageReport = Cine.server_model('stream_usage_report')
_ = require('underscore')

getReportsForProject = (projectId, callback)->
  EdgecastStream.find _project: projectId, (err, streams)->
    return callback(err) if err

    query = _edgecastStream: {$in: _.pluck(streams, 'id')}
    StreamUsageReport.find query, callback

exports.byMonth = (projectId, month, callback)->
  getReportsForProject projectId, (err, reports)->
    return callback(err) if err

    addStreamBytes = (accum, stream)->
      accum + stream.bytesForMonth(month)
    totalProjectBytes = _.reduce reports, addStreamBytes, 0

    callback(null, totalProjectBytes)

exports.total = (projectId, callback)->
  getReportsForProject projectId, (err, reports)->
    return callback(err) if err

    addStreamBytes = (accum, stream)->
      accum + stream.totalBytes()
    totalProjectBytes = _.reduce reports, addStreamBytes, 0

    callback(null, totalProjectBytes)
