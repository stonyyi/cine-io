debug = require('debug')("cine:rtc_transmuxer:index")
Primus = require('primus')
WebRTCBroadcastSession = Cine.app("rtc_transmuxer/lib/webrtc_broadcast_session")
{authenticateSpark, ensureProjectId, invalidPublicKeyOptions} = Cine.server_lib('primus/authenticate_spark')

primusOptions =
  transformer: 'sockjs'
  namespace: 'metroplex'
  # redis: newRedisClient()
  rooms:
    wildcard: false #https://github.com/cayasso/primus-rooms#disabling-wildcard
  # cluster:
  #   redis: newRedisClient

stopAll = (spark)->
  debug("stopping", spark.id)
  for streamType, webRTCBroadcastSession of spark.webRTCBroadcastSessions
    webRTCBroadcastSession.stop()
  delete spark.webRTCBroadcastSessions

stop = (spark, streamType)->
  debug("stopping", spark.id)
  webRTCBroadcastSession = spark.webRTCBroadcastSessions[streamType]
  return unless webRTCBroadcastSession
  webRTCBroadcastSession.stop()
  delete spark.webRTCBroadcastSessions[streamType]

module.exports = (server)->

  primus = new Primus(server, primusOptions)
  newConnection = (spark)->

    spark.webRTCBroadcastSessions = {}

    debug "Connection received with spark.id ", spark.id

    dataHandler = (data)->
      debug "Connection ", spark.id, " received message ", data
      switch data.action
        when "auth"
          authenticateSpark(spark, data)

        when "broadcast-start"
          spark.write action: 'ack', source: 'broadcast-start'
          offer = data.offer?.sdp
          return spark.write(action: 'error', error: 'invalid offer') unless offer
          return spark.write(action: 'error', error: 'stream key and stream id required') if !data.streamId || !data.streamKey
          return spark.write(action: 'error', error: 'streamType required') if !data.streamType
          spark.webRTCBroadcastSessions[data.streamType] = new WebRTCBroadcastSession(data.streamId, data.streamKey)
          spark.webRTCBroadcastSessions[data.streamType].handleOffer offer, (err, sdpAnswer)->
            if err
              stop(spark, data.streamType)
              response =
                streamType: data.streamType
                action: "error"
                error: err
            else
              response =
                streamType: data.streamType
                action: "rtc-answer"
                answer: {type: 'answer', sdp: sdpAnswer}
            debug("RESPONDING", response)
            spark.write(response)

        when "broadcast-stop"
          spark.write action: 'ack', source: 'broadcast-stop'
          stop(spark, data.streamType)
        else
          debug("unknown data", data)

    spark.on 'data', dataHandler

  primus.on 'connection', newConnection

  primus.on 'disconnection', (spark)->
    stopAll(spark)
