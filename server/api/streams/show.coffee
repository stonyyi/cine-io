EdgecastStream = Cine.server_model('edgecast_stream')
fs = require('fs')
profileFileName = "#{Cine.root}/server/api/streams/fmle_profile.xml"

fmleProfile = (stream, callback)->
  fs.readFile profileFileName, 'utf8', (err, profileFile)->
    return callback("cannot read profile", null, status: 500) if err
    content = profileFile
      .toString()
      .replace(/EDGECAST_INSTANCE_NAME/g, stream.instanceName)
      .replace(/EDGECAST_STREAM_NAME/g, stream.streamName)
      .replace(/EDGECAST_STREAM_KEY/g, stream.streamKey)
      .replace(/EDGECAST_EVENT_NAME/g, stream.eventName)
    callback(null, content: content)

toJSON = (stream, callback)->
  streamJSON =
    id: stream._id.toString()
    instanceName: stream.instanceName
    eventName: stream.eventName
    streamName: stream.streamName
    streamKey: stream.streamKey
    expiration: stream.expiration

  callback(null, streamJSON)

Show = (callback)->
  return callback("id required", null, status: 400) unless @params.id
  EdgecastStream.findOne _id: @params.id, _project: @project._id, (err, stream)=>
    return callback(err, null, status: 400) if err
    return callback("stream not found", null, status: 404) unless stream
    return fmleProfile(stream, callback) if @params.fmleProfile == 'true'
    toJSON(stream, callback)

module.exports = Show
module.exports.toJSON = toJSON
module.exports.project = true
