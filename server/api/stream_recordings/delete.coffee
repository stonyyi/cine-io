EdgecastStream = Cine.server_model('edgecast_stream')
getProject = Cine.server_lib('get_project')
deleteStreamRecordingOnEdgecast = Cine.server_lib('delete_stream_recording_on_edgecast')
EdgecastRecordings = Cine.server_model('edgecast_recordings')

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
      deleteStreamRecordingOnEdgecast stream, params.name, (err)->
        query = _edgecastStream: stream._id
        update =
          $pull: {recordings: {name: params.name}}
        options = safe: true, multi: false
        EdgecastRecordings.update query, update, options, (err, numAffected)->
          return callback(err, null, status: 400) if err
          callback(null, deletedAt: new Date)
