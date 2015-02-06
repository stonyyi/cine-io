Base = require('../base')
Cine.config('connect_to_mongo')
runMe = !module.parent

http = require('http')
async = require('async')
Debug = require('debug')
Primus = require('primus')
kurento = require("kurento-client")
EdgecastStream = Cine.server_model('edgecast_stream')

KURENTO_MEDIA_SERVER_HOST = process.env.KURENTO_MEDIA_SERVER_HOST || "kurento-media-server"
KURENTO_PORT = process.env.KURENTO_MEDIA_SERVER_CONNECTION_PORT || 8888
ws_uri = "ws://#{KURENTO_MEDIA_SERVER_HOST}:#{KURENTO_PORT}/kurento"

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
  kurento ws_uri, (err, _kurentoClient) ->
    if err
      debug "Coult not find media server at address " + ws_uri
      return callback("Could not find media server at address" + ws_uri + ". Exiting with err " + err)
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
      uri: "http://192.168.1.139/#{@streamName}/#{@streamKey}"

    debug("creating reporder pipeline", recorderParams)
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

  processOffer: (offer, callback)=>
    @webRtcEndpoint.processOffer offer, (error, sdpAnswer) ->
      return callback(error) if error

      callback null, sdpAnswer

  stop: ->
    @pipeline.release() if @pipeline

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

Base.listen server, 8184 if runMe
