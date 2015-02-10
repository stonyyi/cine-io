Base = require('../base')
runMe = !module.parent

Debug = require('debug')

Debug.enable('cine:*')
debug = Debug("cine:input_to_rtmp_streamer:index")
StreamToRtmpReplicator = Cine.app('input_to_rtmp_streamer/lib/stream_to_rtmp_replicator')

app = exports.app = Base.app("input to rtmp streamer", log: false)

streamers = null
exports._reset = ->
  streamers = new StreamToRtmpReplicator
exports._reset()

app.get '/', (req, res)->
  res.send("I am the input_to_rtmp_streamer")

app.post '/start', (req, res)->
  streamName = req.body.streamName
  streamKey = req.body.streamKey
  input = req.body.input
  debug("starting", streamName, streamKey, input)
  return res.sendStatus(400) if !streamName || !streamKey || !input
  streamers.startStreamer(streamName, streamKey, input)

  res.sendStatus(200)

app.post '/stop', (req, res)->
  streamName = req.body.streamName
  debug("stopping", streamName)
  return res.sendStatus(400) if !streamName
  streamers.stopStreamer(streamName)
  res.sendStatus(200)

Base.listen app, 8185 if runMe
