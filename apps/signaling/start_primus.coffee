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
    @primus.room(room).except(spark.id).write(action: 'member', room: room, sparkId: spark.id)
    callback()

  leftRoom: (spark, room, callback=noop)=>
    console.log('left room', room)
    @primus.room(room).except(spark.id).write(action: 'leave', room: room, sparkId: spark.id)
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

findOrCreatePeerIdentity = (project, identityName, callback)->
  identityParams =
    identity: identityName
    _project: project._id
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
  spark.write action: "allservers", data: allservers

setIdentity = (spark, data, callback)->
  identityName = data.identity
  publicKey = data.publicKey
  projectForPublicKey publicKey, (err, project)->
    return callback(err) if err
    findOrCreatePeerIdentity project, identityName, (err, identity)->
      if err
        console.error("Could not get PeerIdentity", project, identityName)
        return callback(err)
      identity.currentConnections.push
        sparkId: spark.id
        client: data.client
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
module.exports = (server)->

  primus = new Primus(server, primusOptions)
  primus.use('rooms', Rooms)
  primus.use('omega-supreme', OmegaSupreme)
  primus.use('metroplex', Metroplex)

  askSparkToJoinRoomByIdentity = (spark, roomName, data)->
    publicKey = data.publicKey
    projectForPublicKey publicKey, (err, project)->
      if err
        spark.write action: 'error', error: "INVALID_PUBLIC_KEY", message: "invalid publicKey: #{publicKey} provided"
        return

      identityParams =
        identity: data.otheridentity
        _project: project._id

      PeerIdentity.findOne identityParams, (err, identity)->
        if err || !identity
          console.error("COULD NOT FIND OTHER IDENTITY", identityParams)
          return
        if _.isEmpty(identity.currentConnections)
          console.error("NO CURRENT CONNECTIONS", identityParams)
          return
        _.each identity.currentConnections, (otherSparkId)->

          sendToOtherSpark spark, otherSparkId.sparkId.toString(), action: 'incomingcall', room: roomName

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
        # BEGIN PeerConnection events
        when "ice"
          console.log "i am", spark.id
          console.log "sending ice to", data.sparkId, data.candidate
          sendToOtherSpark spark, data.sparkId, action: "ice", candidate: data.candidate

        when "offer"
          # console.log "new offer", data
          console.log "i am", spark.id
          console.log "sending offer to", data.sparkId, data.offer
          sendToOtherSpark spark, data.sparkId, action: "offer", offer: data.offer

        when "answer"
          # console.log "new answer", data
          console.log "i am", spark.id
          console.log "sending answer to", data.sparkId, data.answer
          sendToOtherSpark spark, data.sparkId, action: "answer", answer: data.answer
        # END PeerConnection events

        # BEGIN room events
        when 'join'
          return if spark.connectedRooms[data.room]
          spark.connectedRooms[data.room] = true
          spark.join data.room

        when "leave"
          return unless spark.connectedRooms[data.room]
          delete spark.connectedRooms[data.room]
          spark.leave data.room
        # END room events

        # BEGIN point-to-point calling
        when "identify"
          console.log "i am", spark.id
          setIdentity spark, data, (err, identity)->
            if err == 'project not found'
              spark.write action: 'error', error: "INVALID_PUBLIC_KEY", message: "invalid publicKey: #{data.publicKey} provided"
            else if err
              spark.write action: 'error', error: "UNKNOWN_ERROR", message: err
            else
              spark.identityId = identity._id

        when 'call'
          generateRoomName (err, roomName)->
            return if spark.connectedRooms[roomName]
            spark.connectedRooms[roomName] = true
            askSparkToJoinRoomByIdentity(spark, roomName, data)
            spark.join roomName
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
