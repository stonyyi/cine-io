Base = require('../base')
Cine.config('connect_to_mongo')
runMe = !module.parent

http = require('http')
Debug = require('debug')
Primus = require('primus')
WebRTCBroadcastSession = Cine.app("rtc_transmuxer/lib/webrtc_broadcast_session")

Debug.enable('rtc_transmuxer:*')
debug = Debug("rtc_transmuxer:index")

app = exports.app = Base.app("rtc transmuxer")
server = http.createServer(app)

app.get '/', (req, res)->
  res.send("I am the rtc_transmuxer")

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
  spark.webRTCBroadcastSession?.stop()

primus = new Primus(server, primusOptions)
newConnection = (spark)->

  debug "Connection received with spark.id " + spark.id

  dataHandler = (data)->
    debug "Connection ", spark.id, " received message ", data
    switch data.action
      when "start-broadcast"
        spark.webrtcBroadcastSession = new WebRTCBroadcastSession(data.streamId, data.streamKey)
        offer = data.offer.sdp
        spark.webRTCBroadcastSession.handleOffer offer, (err, sdpAnswer)->
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

  spark.on 'data', dataHandler

primus.on 'connection', newConnection

primus.on 'disconnection', (spark)->
  stop(spark)

Base.listen server, 8184 if runMe
