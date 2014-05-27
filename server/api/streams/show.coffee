EdgecastStream = Cine.server_model('edgecast_stream')
fs = require('fs')
profileFileName = "#{Cine.root}/server/api/streams/fmle_profile.xml"
getProject = Cine.server_lib('get_project')
BASE_URL = "rtmp://fml.cine.io/20C45E"

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

legacyJSON = (stream, callback)->
  fullJSON stream, (err, streamJSON)->
    streamJSON.instanceName = stream.instanceName
    streamJSON.eventName = stream.eventName
    streamJSON.streamName = stream.streamName
    streamJSON.streamKey = stream.streamKey
    callback(null, streamJSON)

playJSON = (stream, callback)->
  streamJSON =
    id: stream._id.toString()
    play:
      hls: "http://hls.cine.io/#{stream.instanceName}/#{stream.eventName}/#{stream.streamName}.m3u8"
      rtmp: "#{BASE_URL}/#{stream.instanceName}/#{stream.streamName}?adbe-live-event=#{stream.eventName}"
  callback(null, streamJSON)

fullJSON = (stream, callback)->
  playJSON stream, (err, streamJSON)->
    streamJSON.publish =
      url: "rtmp://stream.lax.cine.io/20C45E/#{stream.instanceName}"
      stream: "#{stream.streamName}?#{stream.streamKey}&amp;adbe-live-event=#{stream.eventName}"
    streamJSON.expiration = stream.expiration
    callback(null, streamJSON)

Show = (params, callback)->
  getProject params, requires: 'either', (err, project, options)->
    return callback(err, project, options) if err
    return callback("id required", null, status: 400) unless params.id

    EdgecastStream.findOne _id: params.id, _project: project._id, (err, stream)->
      return callback(err, null, status: 400) if err
      return callback("stream not found", null, status: 404) unless stream
      if params.fmleProfile == 'true'
        return callback("api secret required", null, status: 401) unless options.secure
        return fmleProfile(stream, callback)
      return playJSON(stream, callback) unless options.secure
      fullJSON(stream, callback)

module.exports = Show
module.exports.fullJSON = fullJSON
module.exports.playJSON = playJSON
module.exports.legacyJSON = legacyJSON
