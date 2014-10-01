EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastStreamReport = Cine.server_model('edgecast_stream_report')
_ = require('underscore')

getReportsForProject = (projectId, callback)->
  EdgecastStream.find _project: projectId, (err, streams)->
    return callback(err) if err

    query = _edgecastStream: {$in: _.pluck(streams, 'id')}
    EdgecastStreamReport.find query, callback

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
