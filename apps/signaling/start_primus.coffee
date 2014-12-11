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
  # cluster:
  #   redis: newRedisClient

noop = ->
class RoomManager
  constructor: (@primus)->

  joinedRoom: (spark, room, callback=noop)=>
    console.log('joined room', room)
    publicRoom = projectRoomNameWithoutProject(spark, room)
    @primus.room(room).except(spark.id).write(action: 'room-join', room: publicRoom, sparkId: spark.id)
    callback()

  leftRoom: (spark, room, callback=noop)=>
    console.log('left room', room)
    publicRoom = projectRoomNameWithoutProject(spark, room)
    @primus.room(room).except(spark.id).write(action: 'room-leave', room: publicRoom, sparkId: spark.id)
    callback()

  leftRooms: (spark, rooms, callback=noop)=>
    leftRoom = (room, cb)=>
      @leftRoom(spark, room, cb)
    async.each rooms, leftRoom, callback

generateRoomName = (callback)->
  crypto.randomBytes 32, (err, buf)->
    return callback(err) if err
    callback(null, buf.toString('hex'))

projectForPublicKey = (publicKey, callback)->
  projectParams = publicKey: publicKey
  Project.findOne projectParams, (err, project)->
    return callback(err) if err
    unless project
      console.error("COULD NOT FIND PROJECT", publicKey)
      return callback("project not found")
    callback(null, project)

findOrCreatePeerIdentity = (projectId, identityName, callback)->
  identityParams =
    identity: identityName
    _project: projectId
  PeerIdentity.findOne identityParams, (err, identity)->
    return callback(err) if err
    return callback(null, identity) if identity
    identity = new PeerIdentity(identityParams)
    callback(null, identity)

sendSparkIceServers = (spark)->
  allservers = []
  allservers = allservers.concat(iceServers.stunServers)
  allservers = allservers.concat(iceServers.turnServers)
  console.log("sending ice servers", spark.id)
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
      # TODO: change this to check fro connection.sparkId
      if _.findWhere(identity.currentConnections, sparkId: spark.id)
        console.log("PeerIdentity still has current connection")
      else
        console.log("removed currentConnection", identity.currentConnections)

invalidPublicKeyOptions = (publicKey)->
  action: 'error', error: "INVALID_PUBLIC_KEY", message: "invalid publicKey: #{publicKey} provided"

ensureProjectId = (spark, callback)->
  return process.nextTick(callback) if spark.projectId
  spark.projectCallbacks ||= []
  spark.projectCallbacks.push(callback)

callMe = (cb)->
  cb()

authenticateSpark = (spark, publicKey)->
  projectForPublicKey publicKey, (err, project)->
    if err || !project
      if spark.projectCallbacks
        _.each spark.projectCallbacks, (cb)->
          cb("invalid public key")
      return spark.end invalidPublicKeyOptions(publicKey)
    spark.projectId = project._id
    spark.secretKey = project.secretKey
    spark.write action: 'ack', source: 'auth'
    if spark.projectCallbacks
      spark.projectCallbacks.forEach callMe
      delete spark.projectCallbacks

projectRoomName = (spark, roomName)->
  "#{spark.projectId}-#{roomName}"

projectRoomNameWithoutProject = (spark, roomName)->
  regex = new RegExp("^#{spark.projectId}-")
  roomName.replace(regex, '')

module.exports = (server)->

  primus = new Primus(server, primusOptions)
  primus.use('rooms', Rooms)
  primus.use('omega-supreme', OmegaSupreme)
  primus.use('metroplex', Metroplex)

  askSparkToJoinRoomByIdentity = (spark, roomName, data)->
    publicKey = data.publicKey
    ensureProjectId spark, (err)->
      return if err

      identityParams =
        identity: data.otheridentity
        _project: spark.projectId

      PeerIdentity.findOne identityParams, (err, identity)->
        if err || !identity
          console.error("COULD NOT FIND OTHER IDENTITY", identityParams)
          return
        if _.isEmpty(identity.currentConnections)
          console.error("NO CURRENT CONNECTIONS", identityParams)
          return
        _.each identity.currentConnections, (otherSparkId)->

          sendToOtherSpark spark, otherSparkId.sparkId.toString(), action: 'call', room: roomName

  sendToOtherSpark = (senderSpark, receivingSparkId, data)->
    data.sparkId = senderSpark.id
    console.error("sending data to otherSparkId", receivingSparkId, data)
    primus.forward.spark receivingSparkId, data

  roomManager = new RoomManager(primus)

  primus.on 'connection', (spark)->
    console.log("new connection")
    spark.connectedRooms = {}

    spark.on 'data', (data)->
      # iOS sends buffers somehow. Probably double escaped
      if data instanceof Buffer
        data = JSON.parse(data)
      console.log('got spark data', data)

      switch data.action
        when 'auth'
          authenticateSpark(spark, data.publicKey)

        # BEGIN PeerConnection events
        when "rtc-ice"
          console.log "i am", spark.id
          console.log "sending ice to", data.sparkId, data.candidate
          sendToOtherSpark spark, data.sparkId, action: "rtc-ice", candidate: data.candidate
          spark.write action: 'ack', source: 'rtc-ice'

        when "rtc-offer"
          # console.log "new offer", data
          console.log "i am", spark.id
          console.log "sending offer to", data.sparkId, data.offer
          spark.write action: 'ack', source: 'rtc-offer'
          sendToOtherSpark spark, data.sparkId, action: "rtc-offer", offer: data.offer

        when "rtc-answer"
          # console.log "new answer", data
          console.log "i am", spark.id
          console.log "sending answer to", data.sparkId, data.answer
          spark.write action: 'ack', source: 'rtc-answer'
          sendToOtherSpark spark, data.sparkId, action: "rtc-answer", answer: data.answer
        # END PeerConnection events

        # BEGIN room events
        when "room-join"
          ensureProjectId spark, (err)->
            room = data.room
            return if spark.connectedRooms[room]
            spark.connectedRooms[room] = true
            spark.join projectRoomName(spark, room)
            spark.write action: 'ack', source: 'room-join'

        # the inverse of room-join
        # it is the current members of the room telling the spark about themselves
        when "room-announce"
          ensureProjectId spark, (err)->
            room = data.room
            return if spark.connectedRooms[room]
            spark.connectedRooms[room] = true
            sendToOtherSpark spark, data.sparkId, action: "room-announce", room: room
            spark.write action: 'ack', source: 'room-announce'

        when "room-leave"
          ensureProjectId spark, (err)->
            room = data.room
            return unless spark.connectedRooms[room]
            delete spark.connectedRooms[room]
            spark.leave projectRoomName(spark, room)
            spark.write action: 'ack', source: 'room-leave'

        # the inverse of room-leave
        # it is the current members of the room telling the spark about themselves
        when "room-goodbye"
          ensureProjectId spark, (err)->
            room = data.room
            sendToOtherSpark spark, data.sparkId, action: "room-goodbye", room: room
            spark.write action: 'ack', source: 'room-goodbye'
        # END room events

        # BEGIN point-to-point calling
        when "identify"
          console.log "i am", spark.id
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
            askSparkToJoinRoomByIdentity(spark, room, data)
            if !spark.connectedRooms[room]
              spark.connectedRooms[room] = true
              spark.join projectRoomName(spark, room)
            spark.write action: 'ack', source: 'call', room: room

          if data.room?
            makeCall(spark, data.room, data)
          else
            generateRoomName (err, room)->
              makeCall(spark, room, data)

        when "call-reject"
          ensureProjectId spark, (err)->
            room = data.room
            primus.room(projectRoomName(spark, room)).except(spark.id).write(action: 'call-reject', room: room, identity: spark.identity)
            spark.write action: 'ack', source: 'call-reject'
        # END point-to-point calling

        else
          console.log("Unknown action. :(", data)

    # tell client about stun and turn servers and generate nonces
    sendSparkIceServers(spark)

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
Project = Cine.server_model('project')
