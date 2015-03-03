async = require('async')
redis  = require('redis')
_ = require('underscore')
crypto = require('crypto')

iceServers = require('./allservers')
redisConfig = Cine.config('variables/redis')

Primus = require('primus')
Rooms = require('primus-rooms')
Metroplex = require('metroplex')
OmegaSupreme = require('omega-supreme')
PrimusCluster = require('primus-cluster')
validateSecureIdentity = Cine.server_lib('signaling/validate_secure_identity')
RoomManager = Cine.server_lib('signaling/room_manager')
{authenticateSpark, ensureProjectId, invalidPublicKeyOptions} = Cine.server_lib('primus/authenticate_spark')

newRedisClient = ->
  client = redis.createClient(redisConfig.port, redisConfig.host)
  return client unless redisConfig.pass
  client.auth redisConfig.pass, (err)->
    throw err if err
  client

primusOptions =
  transformer: 'sockjs'
  namespace: 'metroplex'
  redis: newRedisClient()
  rooms:
    wildcard: false #https://github.com/cayasso/primus-rooms#disabling-wildcard
  # cluster:
  #   redis: newRedisClient

noop = ->

generateRoomName = (callback)->
  crypto.randomBytes 32, (err, buf)->
    return callback(err) if err
    callback(null, buf.toString('hex'))

findOrCreatePeerIdentity = (projectId, identityName, callback)->
  identityParams =
    identity: identityName
    _project: projectId
  PeerIdentity.findOne identityParams, (err, identity)->
    return callback(err) if err
    return callback(null, identity) if identity
    identity = new PeerIdentity(identityParams)
    callback(null, identity)

sendSparkIceServers = (spark, project)->
  allservers = []
  allservers = allservers.concat(iceServers.stunServers)
  turnWithAuth = _.map iceServers.turnServers, (turnServer)->
    {
      url: turnServer.url
      credential: project.turnPassword
      username: project.publicKey
    }
  # console.log("adding turn with auth", turnWithAuth)
  allservers = allservers.concat turnWithAuth
  # console.log("sending ice servers", spark.id)
  spark.write action: "rtc-servers", data: allservers

setIdentity = (spark, data, callback)->
  identityName = data.identity
  ensureProjectId spark, (err)->
    return callback(err) if err
    return callback("invalid signature") unless validateSecureIdentity(identityName, spark.secretKey, data.timestamp, data.signature)
    findOrCreatePeerIdentity spark.projectId, identityName, (err, identity)->
      if err
        console.error("Could not get PeerIdentity", spark.projectId, identityName)
        return callback(err)
      identity.currentConnections.push
        sparkId: spark.id
        client: data.client
      spark.identity = identityName
      identity.save (err, identity)->
      if err
        console.error("Could not save currentConnection", identity)
        return callback(err)
      callback(null, identity)

removeCurrentConnectionOnIdentity = (spark)->
  return unless spark.identityId
  PeerIdentity.findById spark.identityId, (err, identity)->
    return if err || !identity
    identity.currentConnections = _.reject identity.currentConnections, (connection)->
      connection.sparkId == spark.id

    identity.save (err, identity)->
      if err
        return console.log("could not remove current connection", err)
      # TODO: change this to check for connection.sparkId
      if _.findWhere(identity.currentConnections, sparkId: spark.id)
        console.log("PeerIdentity still has current connection")
      else
        console.log("removed currentConnection", identity.currentConnections)


module.exports = (server)->

  primus = new Primus(server, primusOptions)
  primus.use('rooms', Rooms)
  primus.use('omega-supreme', OmegaSupreme)
  primus.use('metroplex', Metroplex)

  sendToIdentity = (spark, otheridentity, data)->
    ensureProjectId spark, (err)->
      return if err

      identityParams =
        identity: otheridentity
        _project: spark.projectId

      PeerIdentity.findOne identityParams, (err, identity)->
        if err || !identity
          console.error("COULD NOT FIND OTHER IDENTITY", identityParams)
          return
        if _.isEmpty(identity.currentConnections)
          console.error("NO CURRENT CONNECTIONS", identityParams)
          return
        _.each identity.currentConnections, (otherSparkId)->

          sendToOtherSpark spark, otherSparkId.sparkId.toString(), data

  askSparkToJoinRoomByIdentity = (spark, roomName, otheridentity)->
    dataToSend =
      action: 'call'
      room: roomName
      identity: spark.identity
      support: spark.support
    sendToIdentity spark, otheridentity, dataToSend

  sendToOtherSpark = (senderSpark, receivingSparkId, data)->
    data.sparkId = senderSpark.id
    data.sparkUUID = senderSpark.clientUUID
    # console.log("sending data to otherSparkId", receivingSparkId, data)
    primus.forward.spark receivingSparkId, data

  roomManager = new RoomManager(primus)

  primus.on 'connection', (spark)->
    console.log("new connection", spark.id)
    spark.connectedRooms = {}
    # options for support
    #   trickleIce: true|false
    spark.support = {}

    spark.on 'data', (data)->
      # iOS sends buffers somehow. Probably double escaped
      if data instanceof Buffer
        data = JSON.parse(data)
      # console.log('got spark data', data)

      spark.clientUUID ||= data.uuid
      console.log(spark.clientUUID, "sent", data.action)
      switch data.action
        when 'auth'
          # set what the spark supports
          spark.support = data.support
          authenticateSpark spark, data, (err, project)->
            console.log(spark.clientUUID, "support", spark.support)
            sendSparkIceServers(spark, project) unless err

        # BEGIN PeerConnection events
        when "rtc-ice"
          # console.log "i am", spark.id
          # console.log "sending ice to", data.sparkId, data.candidate
          sendToOtherSpark spark, data.sparkId, action: "rtc-ice", candidate: data.candidate, support: spark.support
          spark.write action: 'ack', source: 'rtc-ice'

        when "rtc-offer"
          # console.log "i am", spark.id
          # console.log "sending offer to", data.sparkId, data.offer
          spark.write action: 'ack', source: 'rtc-offer'
          sendToOtherSpark spark, data.sparkId, action: "rtc-offer", offer: data.offer, support: spark.support

        when "rtc-answer"
          # console.log "i am", spark.id
          # console.log "sending answer to", data.sparkId, data.answer
          spark.write action: 'ack', source: 'rtc-answer'
          sendToOtherSpark spark, data.sparkId, action: "rtc-answer", answer: data.answer, support: spark.support
        # END PeerConnection events

        # BEGIN room events
        when "room-join"
          ensureProjectId spark, (err)->
            room = data.room
            return if spark.connectedRooms[room]
            spark.connectedRooms[room] = true
            spark.join RoomManager.projectRoomName(spark, room)
            spark.write action: 'ack', source: 'room-join'

        # the inverse of room-join
        # it is the current members of the room telling the spark about themselves
        when "room-announce"
          ensureProjectId spark, (err)->
            room = data.room
            return if spark.connectedRooms[room]
            spark.connectedRooms[room] = true
            sendToOtherSpark spark, data.sparkId, action: "room-announce", room: room, support: spark.support
            spark.write action: 'ack', source: 'room-announce'

        when "room-leave"
          ensureProjectId spark, (err)->
            room = data.room
            return unless spark.connectedRooms[room]
            delete spark.connectedRooms[room]
            spark.leave RoomManager.projectRoomName(spark, room)
            spark.write action: 'ack', source: 'room-leave'

        # the inverse of room-leave
        # it is the current members of the room telling the spark about themselves
        when "room-goodbye"
          ensureProjectId spark, (err)->
            room = data.room
            sendToOtherSpark spark, data.sparkId, action: "room-goodbye", room: room, support: spark.support
            spark.write action: 'ack', source: 'room-goodbye'
        # END room events

        # BEGIN point-to-point calling
        when "identify"
          # console.log "i am", spark.id
          setIdentity spark, data, (err, identity)->
            if err == 'project not found'
              return spark.write invalidPublicKeyOptions(data.publicKey)

            if err == 'invalid signature'
              return spark.write action: 'error', error: "INVALID_SIGNATURE", message: "invalid signature: #{data.signature} provided"

            if err
              return spark.write action: 'error', error: "UNKNOWN_ERROR", message: err
            spark.identityId = identity._id
            spark.write action: 'ack', source: 'identify'

        when "call"
          makeCall = (spark, room, data)->
            ensureProjectId spark, ->
              otheridentity = data.otheridentity
              askSparkToJoinRoomByIdentity(spark, room, otheridentity)
              if !spark.connectedRooms[room]
                spark.connectedRooms[room] = true
                spark.join RoomManager.projectRoomName(spark, room)
              dataToSend =
                action: 'ack'
                source: 'call'
                room: room
                otheridentity: otheridentity
              # console.log("ACKING", dataToSend)
              spark.write dataToSend

          if data.room?
            makeCall(spark, data.room, data)
          else
            generateRoomName (err, room)->
              makeCall(spark, room, data)

        when "call-reject"
          ensureProjectId spark, (err)->
            room = data.room
            primus.room(RoomManager.projectRoomName(spark, room)).except(spark.id).write(action: 'call-reject', room: room, identity: spark.identity, sparkUUID: spark.clientUUID, support: spark.support)
            spark.write action: 'ack', source: 'call-reject', room: data.room

        when "call-cancel"
          ensureProjectId spark, (err)->
            dataToSend =
              action: 'call-cancel'
              room: data.room
              identity: spark.identity
              support: spark.support
            sendToIdentity spark, data.otheridentity, dataToSend
            spark.write action: 'ack', source: 'call-cancel', room: data.room, otheridentity: data.otheridentity
        # END point-to-point calling

        else
          console.log("Unknown action. :(", data)

  primus.on 'disconnection', (spark)->
    console.log(spark.id + ' disconnected')
    removeCurrentConnectionOnIdentity(spark)

  primus.on 'joinroom', (room, spark)->
    console.log(spark.id + ' joined ' + room)
    roomManager.joinedRoom spark, room

  # not called on disconnect, leaveallrooms is called
  primus.on 'leaveroom', (room, spark)->
    console.log(spark.id + ' left ' + room)
    roomManager.leftRoom spark, room

  primus.on 'leaveallrooms', (rooms, spark)->
    roomManager.leftRooms(spark, rooms)
    console.log('spark left all rooms', spark.id, rooms)

PeerIdentity = Cine.server_model('peer_identity')
