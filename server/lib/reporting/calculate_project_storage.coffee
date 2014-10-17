EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastRecordings = Cine.server_model('edgecast_recordings')
_ = require('underscore')

getRecordingsForProject = (project, callback)->
  EdgecastStream.find _project: project._id, (err, streams)->
    return callback(err) if err

    query = _edgecastStream: {$in: _.pluck(streams, 'id')}
    EdgecastRecordings.find query, callback

exports.byMonth = (project, month, callback)->
  getRecordingsForProject project, (err, reports)->
    return callback(err) if err

    addRecordingSize = (accum, recording)->
      accum + recording.bytesForMonth(month)
    totalProjectBytes = _.reduce reports, addRecordingSize, 0

    callback(null, totalProjectBytes)

exports.total = (project, callback)->
  getRecordingsForProject project, (err, recordings)->
    return callback(err) if err

    addRecordingSize = (accum, recording)->
      accum + recording.totalBytes()
    totalProjectBytes = _.reduce recordings, addRecordingSize, 0

    callback(null, totalProjectBytes)
