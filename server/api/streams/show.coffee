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

  options.server ||= NearestServer.default.server

  fs.readFile profileFileName, 'utf8', (err, profileFile)->
    return callback("cannot read profile", null, status: 500) if err
    content = profileFile
      .toString()
      .replace(/SERVER_URL/g, options.server)
      .replace(/STREAM_NAME/g, stream.streamName)
      .replace(/STREAM_KEY/g, stream.streamKey)
      .replace(/EVENT_NAME/g, stream.eventName)
    callback(null, content: content)

playJSON = (project, stream, callback)->
  streamJSON =
    id: stream._id.toString()
    name: stream.name
    streamName: stream.streamName
    play:
      hls: "http://hls.cine.io/#{project.publicKey}/#{stream.streamName}.m3u8" # ours
      # hls: "http://hls2.cine.io/#{stream.instanceName}/#{stream.eventName}/#{stream.streamName}.m3u8" #edgecast
      rtmp: "#{BASE_URL}/#{stream.instanceName}/#{stream.streamName}"
  callback(null, streamJSON)

fullJSON = (project, stream, options, callback)->
  if typeof options == "function"
    callback = options
    options = {}

  options.server ||= NearestServer.default.server

  playJSON project, stream, (err, streamJSON)->
    streamJSON.publish =
      url: options.server
      stream: "#{stream.streamName}?#{stream.streamKey}"
    streamJSON.password = stream.streamKey
    streamJSON.expiration = stream.expiration
    streamJSON.record = stream.record
    streamJSON.assignedAt = stream.assignedAt
    streamJSON.deletedAt = stream.deletedAt if stream.deletedAt
    callback(null, streamJSON)

addEdgecastServerToStreamOptions = (streamOptions, params)->
  response = NearestServer.convert params
  return unless _.has(response, 'server')
  streamOptions.server = response.server

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
      return playJSON(project, stream, callback) unless options.secure
      addEdgecastServerToStreamOptions(streamOptions, params)
      fullJSON(project, stream, streamOptions, callback)

module.exports = Show
module.exports.fullJSON = fullJSON
module.exports.addEdgecastServerToStreamOptions = addEdgecastServerToStreamOptions
module.exports.playJSON = playJSON
