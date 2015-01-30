_ = require('underscore')
Base = require('../base')
Cine.config('connect_to_mongo')
runMe = !module.parent
EdgecastStream = Cine.server_model('edgecast_stream')
request = require('request')
Primus = require('primus')
http = require('http')

app = exports.app = Base.app("rtc transmuxer")

server = http.createServer(app)

app.get '/', (req, res)->
  res.send("I am the rtc_transmuxer")

fs = require('fs')
kurento = require("kurento-client")
path = require("path")
async = require('async')
Debug = require('debug')
Debug.enable('rtc_transmuxer:*')
debug = Debug("rtc_transmuxer:index")
cp = require('child_process')
tailingStream = require('tailing-stream')

ffmpeg = "ffmpeg"

RTMP_REPLICATOR_HOST = process.env.RTMP_REPLICATOR_HOST || 'rtmp-replicator'
RTMP_AUTHENTICATOR_HOST = process.env.RTMP_AUTHENTICATOR_HOST || 'rtmp-authenticator'
KURENTO_MEDIA_SERVER_HOST = process.env.KURENTO_MEDIA_SERVER_HOST || "kurento-media-server"
KURENTO_PORT = process.env.KURENTO_MEDIA_SERVER_PORT || 8888
DOCKER_PATH = "/var/rtc-recordings"
TEMP_HOST_PATH = "/Users/thomas/work/tmp"
ws_uri = "ws://#{KURENTO_MEDIA_SERVER_HOST}:#{KURENTO_PORT}/kurento"

class TailingFFMpegStreamer
  constructor: (@input, @output)->
  start: ->
    @_startReadStream()
    @_startFfmpeg()
    @_sendDataToFfmpeg()

  _startReadStream: ->
    debug("tailing", @input)
    @readStream = tailingStream.createReadStream(@input)

  _startFfmpeg: ->
    ffmpegOptions = [
      '-re', # read in "real time", don't read too quickly
      '-i', 'pipe:0', # take stdin as the input
      '-c:v', 'copy', # h.264

      #for audio, it outputs in mp3, we can either:
      # change it to aac:
      '-c:a', 'libfdk_aac',
      # or downsample to 44100:
      # '-ar', '44100',
      # end audio
      '-c:d', 'copy', # don't think this does anything
      '-map', '0',
      '-f', 'flv',
      @output
    ]

    debug('running ffmpeg', ffmpegOptions)
    @ffmpegSpawn = cp.spawn(ffmpeg, ffmpegOptions)

    @ffmpegSpawn.stderr.setEncoding('utf8')
    @ffmpegSpawn.stderr.on 'data', (data)->
      if (/^execvp\(\)/.test(data))
        debug('Failed to start child process.')
      debug("ffmpeg stderr", data)

    @ffmpegSpawn.on 'close', (code)->
      if code != 0
        debug('ffmpeg process exited with code ' + code)
      debug("ffmpeg done")

  _sendDataToFfmpeg: ->
    @readStream.pipe(@ffmpegSpawn.stdin)

  stop: ->
    @readStream.destroy() if @readStream
    @ffmpegSpawn.kill('SIGHUP') if @ffmpegSpawn

runFfmpeg = (input, output)->
  streamer = new TailingFFMpegStreamer(input, output)
  streamer.start()
  return streamer

idCounter = 0
kurentoClient = null

nextUniqueId = ->
  idCounter++
  idCounter.toString()


# Recover kurentoClient for the first time.
getKurentoClient = (callback) ->
  return callback(null, kurentoClient) if kurentoClient isnt null
  kurento ws_uri, (err, _kurentoClient) ->
    if err
      debug "Coult not find media server at address " + ws_uri
      return callback("Could not find media server at address" + ws_uri + ". Exiting with err " + err)
    kurentoClient = _kurentoClient
    callback null, kurentoClient


class RecorderPipeline
  constructor: (@kurentoClient)->
  create: (callback)=>
    debug("createing pipeline")
    @_createUniqueFile()

    @_createWebRtcEndpoint (err, @webRtcEndpoint)=>
      callback(err)

  _createWebRtcEndpoint: (callback)=>

    recorderParams =
      stopOnEndOfStream: true
      mediaProfile: 'MP4'
      uri: "file://#{@dockerFile}"

    @kurentoClient.create "MediaPipeline", (err, pipeline)=>
      return callback(err) if err
      @pipeline = pipeline
      asynCalls =
        recorder: (cb)->
          pipeline.create "RecorderEndpoint", recorderParams, (err, recorder) ->
            return cb(err) if err
            debug("created recorder", recorder)
            recorder.record (err)-> debug("STARTING RECORDER", err)
            cb(null, recorder)
        webRtcEndpoint: (cb)->
          pipeline.create "WebRtcEndpoint", (err, webRtcEndpoint) ->
            debug("CREATED WebRtcEndpoint", err, webRtcEndpoint)
            return cb(err) if err
            cb(null, webRtcEndpoint)

      async.parallel asynCalls, (err, result)->
        return callback(err) if err

        webRtcEndpoint = result.webRtcEndpoint
        webRtcEndpoint.connect result.recorder, (err)->
          callback(err, webRtcEndpoint)

  _createUniqueFile: =>
    date = (new Date).toISOString().replace(/[-:.]/g, '')
    file = "#{date}.mp4"

    @dockerFile = "#{DOCKER_PATH}/#{file}"
    @fileSystemFile = "#{TEMP_HOST_PATH}/#{file}"

  processOffer: (offer, callback)=>
    @webRtcEndpoint.processOffer offer, (error, sdpAnswer) ->
      return callback(error) if error

      callback null, sdpAnswer

  broadcast: (stream, streamKey)=>

    # output = "rtmp://stream.lax.cine.io/20C45E/cines/#{stream.streamName}?#{streamKey}"

    output = "rtmp://#{RTMP_REPLICATOR_HOST}:1935/live/#{stream.streamName}?#{streamKey}"
    debug("streaming to", output)

    @streamer = runFfmpeg(@fileSystemFile, output)

  stop: ->
    @pipeline.release() if @pipeline
    @streamer.stop() if @streamer

getStream = (streamId, streamKey, callback)->
  EdgecastStream.findById streamId, (err, stream)->
    return callback(err) if err

    options =
      url: "http://#{RTMP_AUTHENTICATOR_HOST}/"
      streamName: stream.streamName
    options[streamKey] = true
    # request.post options, (err, response, body)->
    #   return callback(err) if err
    #   return callback(body) if response.statusCode != 200
    callback(null, stream)

createBroadcaster = (webRTCBroadcastSession, sdp, streamId, streamKey, callback) ->
  getStream streamId, streamKey, (err, stream)->
    return callback(err) if err
    getKurentoClient (err, kurentoClient) ->
      return callback(err) if err
      debug("got kurentoClient")
      pipeline = new RecorderPipeline(kurentoClient)
      webRTCBroadcastSession.setRecorderPipeline(pipeline)
      pipeline.create (err)->
        return callback(err) if err
        debug("created pipeline")

        pipeline.processOffer sdp.sdp, (err, sdpAnswer)->
          callback(err, sdpAnswer)

          pipeline.broadcast(stream, streamKey)

webRTCBroadcastSessions = {}

class WebRTCBroadcastSession
  constructor: (@spark)->
  setRecorderPipeline: (@recorderPipeline)->
  stop: ->
    @recorderPipeline.stop() if @recorderPipeline


primusOptions =
  transformer: 'sockjs'
  namespace: 'metroplex'
  # redis: newRedisClient()
  rooms:
    wildcard: false #https://github.com/cayasso/primus-rooms#disabling-wildcard
  # cluster:
  #   redis: newRedisClient


stop = (spark)->
  session = webRTCBroadcastSessions[spark.id]
  return unless session
  session.stop()
  delete webRTCBroadcastSessions[spark.id]

primus = new Primus(server, primusOptions)
primus.on 'connection', (spark)->

  debug "Connection received with spark.id " + spark.id
  webRTCBroadcastSessions[spark.id] = new WebRTCBroadcastSession(spark)

  spark.on 'data', (data)->
    debug "Connection " + spark.id + " received message ", data
    switch data.action
      when "start-broadcast"
        createBroadcaster webRTCBroadcastSessions[spark.id], data.offer, data.streamId, data.streamKey, (err, sdpAnswer) ->
          if err
            response =
              action: "error"
              data: err
          else
            response =
              action: "rtc-answer"
              answer: {type: 'answer', sdp: sdpAnswer}
          debug("RESPONDING", response)
          spark.write(response)

      when "stop-broadcast"
        stop(spark)
      when "auth"
        # TODO
        # stop(spark)
      else
        response =
          id: "error"
          data: "Invalid data " + data
        spark.write(response)

primus.on 'disconnection', (spark)->
  stop(spark)

Base.listen server, 8184 if runMe
