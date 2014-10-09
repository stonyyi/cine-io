Base = require('./base')
Cine.config('connect_to_mongo')
fs = require('fs')
request = require('request')
runMe = !module.parent

streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')
vodTranslatorHost = "vod-translator"
EdgecastFtpInfo = Cine.config('edgecast_ftp_info')
EdgecastStream = Cine.server_model('edgecast_stream')

app = exports.app = Base.app()

class RemoveStreamRecording
  constructor: (@fullFileName)->
  process: (callback)=>
    console.log("Deleting", @fullFileName)
    fs.unlink @fullFileName, callback

class SaveStreamRecording
  constructor: (@fullFileName)->
  process: (callback)=>
    requestOptions =
      method: "POST"
      url: "http://#{vodTranslatorHost}/"
      json:
        file: @fullFileName
        format: 'mp4'
        videoCodec: 'copy'
        audioCodec: 'copy'
        dataCodec: 'copy'
        extra: "-movflags faststart"
    console.log("posting", requestOptions)

    request requestOptions, (err, res, body)->
      if err
        console.log("request err", err)
        return callback(err)
      return callback(message: "not 200", status: res.statusCode, body: body) if res.statusCode != 200
      callback()

class NewRecordingHandler
  constructor: (@fullFileName)->
  process: (callback)=>
    @_findEdgecastStream (err, stream)=>
      return callback(err) if err
      unless stream
        console.log("Stream not found", @fullFileName)
        return callback("stream not found")
      HandlerClass = if stream.record then SaveStreamRecording else RemoveStreamRecording
      handler = new HandlerClass(@fullFileName, stream)
      handler.process(callback)

  _findEdgecastStream: (callback)=>
    streamName = streamRecordingNameEnforcer.extractStreamNameFromDirectory(@fullFileName)
    query =
      streamName: streamName
      instanceName: EdgecastFtpInfo.vodDirectory
    EdgecastStream.findOne query, callback

# takes a /?file=/aboslute/path/to/file
app.post '/', (req, res)->
  file = req.body?.file
  return res.status(400).send("usage: [POST] /, {file: '/full/path/to/file'}") unless file
  fs.exists file, (exists)->
    return res.status(400).send("Could not find file #{file}") unless exists

    handler = new NewRecordingHandler(file)
    handler.process (err)->
      if err
        console.log("Could not process file", file, err)
      else
        console.log("Processed file successfully", file)

    res.send("OK")

Base.listen app, 8182 if runMe
