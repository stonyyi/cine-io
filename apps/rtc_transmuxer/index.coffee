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
CHUNKED_RTMP_STREMER_HOST = process.env.CHUNKED_RTMP_STREMER_HOST || 'chunked-rtmp-streamer'
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


class RecorderPipeline
  constructor: (@kurentoClient, @streamName, @streamKey)->
  create: (callback)=>
    debug("createing pipeline")

    @_createWebRtcEndpoint (err, @webRtcEndpoint)=>
      callback(err)

  _createWebRtcEndpoint: (callback)=>

    recorderParams =
      stopOnEndOfStream: true
      mediaProfile: 'MP4'
      uri: "http://#{CHUNKED_RTMP_STREMER_HOST}/#{@streamName}/#{@streamKey}"

    debug("creating reporder pipeline", recorderParams)
    @kurentoClient.create "MediaPipeline", (err, pipeline)=>
      return callback(err) if err
      @pipeline = pipeline
      asynCalls =
        recorder: (cb)->
          pipeline.create "RecorderEndpoint", recorderParams, (err, recorderEndpoint) ->
            return cb(err) if err
            debug("created recorderEndpoint", recorderEndpoint)

            recorderEndpoint.record (err)-> debug("starting recorder", err)
            cb(null, recorderEndpoint)
        webRtcEndpoint: (cb)->
          pipeline.create "WebRtcEndpoint", (err, webRtcEndpoint) ->
            debug("CREATED WebRtcEndpoint", err, webRtcEndpoint)
            # THis stuff is useless. The MediaSessionStarted does work
            # But the MediaSessionTerminated never fired
            # webRtcEndpoint.on 'MediaSessionStarted', (stuff)->
            #   debug('webRtcEndpoint', 'MediaSessionStarted', stuff)
            # webRtcEndpoint.on 'MediaSessionTerminated', (stuff)->
            #   debug('webRtcEndpoint', 'MediaSessionTerminated', stuff)
            return cb(err) if err
            cb(null, webRtcEndpoint)

      pipeline.on 'release', ->
        debug("released")

      async.parallel asynCalls, (err, result)->
        return callback(err) if err

        webRtcEndpoint = result.webRtcEndpoint
        webRtcEndpoint.connect result.recorder, (err)->
          # webRtcEndpoint.connect result.httpGet, (err)->
          callback(err, webRtcEndpoint)

  processOffer: (offer, callback)=>
    @webRtcEndpoint.processOffer offer, (error, sdpAnswer) ->
      return callback(error) if error

      callback null, sdpAnswer

  _notifyChunkedRtmpStreamer: ->
    options =
      url: "http://#{CHUNKED_RTMP_STREMER_HOST}/stop"
      json: true
      body:
        streamName: @streamName
    debug("stopping chunked-rtmp-streamer", options)
    request.post options, (err, response, body)->
      return debug("_notifyChunkedRtmpStreamer", "err", err) if err
      return debug("_notifyChunkedRtmpStreamer", "not 200", response.statusCode, body) if response.statusCode != 200
      # do nothing

  stop: ->
    @pipeline.release() if @pipeline
    @_notifyChunkedRtmpStreamer()

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
      pipeline = new RecorderPipeline(kurentoClient, stream.streamName, streamKey)
      webRTCBroadcastSession.setRecorderPipeline(pipeline, stream.streamName, streamKey)
      pipeline.create (err)->
        return callback(err) if err
        debug("created pipeline")

        pipeline.processOffer sdp.sdp, (err, sdpAnswer)->
          callback(err, sdpAnswer)

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
        # stop(spark)
      else
        response =
          id: "error"
          data: "Invalid data " + data
        spark.write(response)

primus.on 'disconnection', (spark)->
  stop(spark)
  delete webRTCBroadcastSessions[spark.id]

Base.listen server, 8184 if runMe
