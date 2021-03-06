_ = require('underscore')
EdgecastStream = Cine.server_model('edgecast_stream')
getProject = Cine.server_lib('get_project')
StreamRecordings = Cine.server_model('stream_recordings')
async = require('async')
canCastAsObjectId = Cine.server_lib('can_cast_as_object_id')

isDeleted = (item)->
  item.deletedAt

module.exports = (params, callback)->
  getProject params, requires: 'either', userOverride: true, (err, project, options)->
    return callback(err, project, options) if err
    return callback("id required", null, status: 400) unless params.id
    return callback("stream not found", null, status: 404) unless canCastAsObjectId(params.id)

    toRecordingJSON = (recording)->
      name: recording.name
      url: "http://vod.cine.io/cines/#{project.publicKey}/#{recording.name}"
      size: recording.size
      date: recording.date

    # I want to validate that the project owns the stream
    # so I do both queries at once, this should make the positive case faster
    # the err needs to be the the name of the call
    # this allows us to return the proper response
    asyncCalls =
      findStream: (cb)->
        query =
          _id: params.id
          _project: project._id
          deletedAt:
            $exists: false
        EdgecastStream.findOne query, (err, stream)->
          return cb("findStream", err, null, status: 400) if err
          return cb("findStream", "stream not found", null, status: 404) unless stream
          cb(null, err, stream)
      findRecordings: (cb)->
        query =
          _edgecastStream: params.id
        StreamRecordings.findOne query, (err, edgecastRecordings)->
          return cb("findRecordings", err, null, status: 400) if err
          return cb(null, null, []) unless edgecastRecordings
          response = _.chain(edgecastRecordings.recordings)
            .reject(isDeleted)
            .map(toRecordingJSON)
            .value()
          cb(null, null, response)

    async.parallel asyncCalls, (err, response)->
      return callback(response[err]...) if err
      callback(response.findRecordings...)
