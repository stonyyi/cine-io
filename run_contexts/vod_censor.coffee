Base = require('./base')
Cine.config('connect_to_mongo')
fs = require('fs')
request = require('request')
runMe = !module.parent

streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')
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
    Base.scheduleJob Base.getQueueName('vod_translator'), file:  @fullFileName, callback

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

app.get '/', (req, res)->
  res.send("I am the vod_censor")

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
        console.log("Processed file", file)

    res.send("OK")

Base.listen app, 8182 if runMe
