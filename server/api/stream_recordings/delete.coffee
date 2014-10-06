EdgecastStream = Cine.server_model('edgecast_stream')
getProject = Cine.server_lib('get_project')
deleteStreamRecordingOnEdgecast = Cine.server_lib('delete_stream_recording_on_edgecast')
EdgecastRecordings = Cine.server_model('edgecast_recordings')
_ = require('underscore')

findRecording = (recordings, name)->
  _.find recordings.recordings, (recording)->
    recording.name == name && recording.deletedAt is undefined

module.exports = (params, callback)->
  getProject params, requires: 'secret', userOverride: true, (err, project, options)->
    return callback(err, project, options) if err
    return callback("id required", null, status: 400) unless params.id
    query =
      _id: params.id
      _project: project._id
      deletedAt:
        $exists: false

    EdgecastStream.findOne query, (err, stream)->
      return callback(err, null, status: 400) if err
      return callback("stream not found", null, status: 404) unless stream
      return callback("name required", null, status: 404) unless params.name
      query = _edgecastStream: stream._id
      EdgecastRecordings.findOne query, (err, recordings)->
        return callback(err, null, status: 400) if err
        return callback("recording not found", null, status: 404) unless recordings
        savedRecordingEntry = findRecording(recordings, params.name)
        return callback("recording not found", null, status: 404) unless savedRecordingEntry

        deleteStreamRecordingOnEdgecast stream, params.name, (err)->
          deletedAt = new Date
          savedRecordingEntry.deletedAt = deletedAt
          recordings.save (err)->
            return callback(err, null, status: 400) if err
            callback(null, deletedAt: deletedAt)
