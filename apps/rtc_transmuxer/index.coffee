Base = require('../base')
Cine.config('connect_to_mongo')
runMe = !module.parent

http = require('http')
request = require('request')
async = require('async')
Debug = require('debug')
Primus = require('primus')
kurento = require("kurento-client")
EdgecastStream = Cine.server_model('edgecast_stream')

RTMP_AUTHENTICATOR_HOST = process.env.RTMP_AUTHENTICATOR_HOST || 'rtmp-authenticator'
INPUT_TO_RTMP_STREAMER_HOST = process.env.INPUT_TO_RTMP_STREAMER_HOST || 'input-to-rtmp-streamer'
KURENTO_MEDIA_SERVER_HOST = process.env.KURENTO_MEDIA_SERVER_HOST || "kurento-media-server"
kurentoWebsocketUri = "ws://#{KURENTO_MEDIA_SERVER_HOST}/kurento"

Debug.enable('rtc_transmuxer:*')
debug = Debug("rtc_transmuxer:index")

app = exports.app = Base.app("rtc transmuxer")
server = http.createServer(app)

app.get '/', (req, res)->
  res.send("I am the rtc_transmuxer")


kurentoClient = null
# Recover kurentoClient for the first time.
getKurentoClient = (callback) ->
  return callback(null, kurentoClient) if kurentoClient isnt null
  debug("Connecting to kurento at", kurentoWebsocketUri)
  kurento kurentoWebsocketUri, (err, _kurentoClient) ->
    if err
      debug "Coult not find media server at address " + kurentoWebsocketUri
      return callback("Could not find media server at address" + kurentoWebsocketUri + ". Exiting with err " + err)
    kurentoClient = _kurentoClient
    callback null, kurentoClient


class BroadcastPipeline
  constructor: (@kurentoClient, @streamName, @streamKey)->
  create: (callback)=>
    debug("creating pipeline")

    @_createWebRtcEndpoint (err, @result)=>
      @webRtcEndpoint = @result.webRtcEndpoint
      @httpGetEndpoint = @result.httpGetEndpoint
      @webRtcEndpoint.connect @httpGetEndpoint, callback

  _createWebRtcEndpoint: (callback)=>

    @kurentoClient.create "MediaPipeline", (err, @pipeline)=>
      debug('got pipeline')
      return callback(err) if err
      asynCalls =
        httpGetEndpoint: (cb)->
          options =
            terminateOnEOS: true
            mediaProfile: 'WEBM'
          pipeline.create "HttpGetEndpoint", options, cb
        webRtcEndpoint: (cb)->
          pipeline.create "WebRtcEndpoint", cb

      # pipeline.on 'release', ->
      #   debug("released")

      async.parallel asynCalls, callback


  processOffer: (offer, callback)=>
    @webRtcEndpoint.processOffer offer, (error, sdpAnswer) ->
      return callback(error) if error
      callback null, sdpAnswer

  _stopChunkedRtmpStreamer: ->
    options =
      url: "http://#{INPUT_TO_RTMP_STREAMER_HOST}/stop"
      json: true
      body:
        streamName: @streamName
    debug("stopping chunked-rtmp-streamer", options)
    request.post options, (err, response, body)->
      return debug("_stopChunkedRtmpStreamer", "err", err) if err
      return debug("_stopChunkedRtmpStreamer", "not 200", response.statusCode, body) if response.statusCode != 200
      # do nothing

  _startChunkedRtmpStreamer: (input)->
    options =
      url: "http://#{INPUT_TO_RTMP_STREAMER_HOST}/start"
      json: true
      body:
        streamName: @streamName
        streamKey: @streamKey
        input: input
    debug("starting chunked-rtmp-streamer", options)
    request.post options, (err, response, body)->
      return debug("_startChunkedRtmpStreamer", "err", err) if err
      return debug("_startChunkedRtmpStreamer", "not 200", response.statusCode, body) if response.statusCode != 200
      # do nothing
  start: ->
    @httpGetEndpoint.getUrl @_startStreaming
  _startStreaming: (err, url)=>
    debug("GOT URL", err, url)
    return if err || !url

    url = url.replace('kurento-media-server', 'docker-local.cine.io') if process.env.REPLACE_WITH_LOCAL

    @_startChunkedRtmpStreamer(url)

  stop: ->
    @pipeline.release() if @pipeline
    @_stopChunkedRtmpStreamer()

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
      pipeline = new BroadcastPipeline(kurentoClient, stream.streamName, streamKey)
      webRTCBroadcastSession.setPipeline(pipeline, stream.streamName, streamKey)
      pipeline.create (err)->
        return callback(err) if err
        debug("created pipeline")

        pipeline.processOffer sdp.sdp, (err, sdpAnswer)->
          callback(err, sdpAnswer)
          pipeline.start()

webRTCBroadcastSessions = {}

class WebRTCBroadcastSession
  constructor: (@spark)->
  setPipeline: (@pipeline)->
  stop: ->
    @pipeline.stop() if @pipeline

primusOptions =
  transformer: 'sockjs'
  namespace: 'metroplex'
  # redis: newRedisClient()
  rooms:
    wildcard: false #https://github.com/cayasso/primus-rooms#disabling-wildcard
  # cluster:
  #   redis: newRedisClient

stop = (spark)->
  debug("stopping", spark.id)
  session = webRTCBroadcastSessions[spark.id]
  return unless session
  session.stop()

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
              streamType: data.streamType
              action: "error"
              data: err
          else
            response =
              streamType: data.streamType
              action: "rtc-answer"
              answer: {type: 'answer', sdp: sdpAnswer}
          debug("RESPONDING", response)
          spark.write(response)

      when "stop-broadcast"
        stop(spark)
      when "auth"
        # TODO
      else
        response =
          id: "error"
          data: "Invalid data " + data
        spark.write(response)

primus.on 'disconnection', (spark)->
  stop(spark)
  delete webRTCBroadcastSessions[spark.id]

Base.listen server, 8184 if runMe
