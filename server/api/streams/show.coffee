EdgecastStream = Cine.server_model('edgecast_stream')
fs = require('fs')
profileFileName = "#{Cine.root}/server/api/streams/fmle_profile.xml"
getProject = Cine.server_lib('get_project')
BASE_URL = "rtmp://fml.cine.io/20C45E"
convertIpAddressToEdgecastServer = Cine.server_lib('convert_ip_address_to_edgecast_server')
NearestServer = Cine.api('server/nearest')
_ = require('underscore')

fmleProfile = (stream, options, callback)->
  if typeof options == "function"
    callback = options
    options = {}

  options.code ||= NearestServer.default.code

  fs.readFile profileFileName, 'utf8', (err, profileFile)->
    return callback("cannot read profile", null, status: 500) if err
    content = profileFile
      .toString()
      .replace(/EDGECAST_SERVER_NAME/g, options.code)
      .replace(/EDGECAST_INSTANCE_NAME/g, stream.instanceName)
      .replace(/EDGECAST_STREAM_NAME/g, stream.streamName)
      .replace(/EDGECAST_STREAM_KEY/g, stream.streamKey)
      .replace(/EDGECAST_EVENT_NAME/g, stream.eventName)
    callback(null, content: content)

playJSON = (stream, callback)->
  streamJSON =
    id: stream._id.toString()
    name: stream.name
    streamName: stream.streamName
    play:
      hls: "http://hls.cine.io/#{stream.instanceName}/#{stream.eventName}/#{stream.streamName}.m3u8"
      rtmp: "#{BASE_URL}/#{stream.instanceName}/#{stream.streamName}?adbe-live-event=#{stream.eventName}"
  callback(null, streamJSON)

fullJSON = (stream, options, callback)->
  if typeof options == "function"
    callback = options
    options = {}

  options.server ||= NearestServer.default.url
  options.transcode ||= NearestServer.default.transcode

  playJSON stream, (err, streamJSON)->
    streamJSON.publish =
      url: options.server
      transcode: options.transcode
      stream: "#{stream.streamName}?#{stream.streamKey}&amp;adbe-live-event=#{stream.eventName}"
    streamJSON.password = stream.streamKey
    streamJSON.expiration = stream.expiration
    streamJSON.record = stream.record
    streamJSON.assignedAt = stream.assignedAt
    streamJSON.deletedAt = stream.deletedAt if stream.deletedAt
    callback(null, streamJSON)

addEdgecastServerToStreamOptions = (streamOptions, params)->
  response = NearestServer.convert params
  return unless _.has(response, 'code')
  streamOptions.code = response.code
  streamOptions.server = response.server
  streamOptions.transcode = response.transcode

Show = (params, callback)->
  getProject params, requires: 'either', (err, project, options)->
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
      streamOptions = {}
      if params.fmleProfile == 'true'
        return callback("secret key required", null, status: 401) unless options.secure
        addEdgecastServerToStreamOptions(streamOptions, params)
        return fmleProfile(stream, streamOptions, callback)
      return playJSON(stream, callback) unless options.secure
      addEdgecastServerToStreamOptions(streamOptions, params)
      fullJSON(stream, streamOptions, callback)

module.exports = Show
module.exports.fullJSON = fullJSON
module.exports.addEdgecastServerToStreamOptions = addEdgecastServerToStreamOptions
module.exports.playJSON = playJSON
