async = require('async')
logEventInKeen = Cine.server_lib('reporting/peer/log_event_in_keen')
redisClient = Cine.server_lib('redis_client')
noop = ->

sparkRoomKey = (spark, room)->
  "signaling:#{spark.clientUUID}-#{room}-join"

sendJoinToRedis = (spark, room, callback)->
  # http://redis.io/commands/setnx
  # set without overwriting existing value
  value = Date.now()
  redisClient.setnx sparkRoomKey(spark, room), value, callback

sendTalkTimeToKeen = (spark, room, callback)->
  key = sparkRoomKey(spark, room)
  scope = redisClient.multi().get(key).del(key)
  endTime = Date.now()
  scope.exec (err, replies)->
    return callback(err) if err
    unless replies?[0]
      # TODO, do something about leaving without joining
      return callback()
    startTime = replies[0]
    extraData =
      signalingClient: spark.signalingClient
      talkTimeInMilliseconds: endTime - startTime
    extraData.identity = spark.identity  if spark.identity
    extraData.identityId = spark.identityId if spark.identityId
    # console.log("SENDING EVENT", extraData)
    logEventInKeen.userTalkedInRoom spark.projectId, room, spark.clientUUID, extraData, callback

module.exports = class RoomManager
  constructor: (@primus)->

  @projectRoomName: (spark, roomName)->
    "#{spark.projectId}-#{roomName}"

  @projectRoomNameWithoutProject: (spark, roomName)->
    regex = new RegExp("^#{spark.projectId}-")
    roomName.replace(regex, '')

  joinedRoom: (spark, room, callback=noop)=>
    # console.log('joined room', room)
    asyncCalls =
      redisLog: (cb)->
        sendJoinToRedis(spark, room, cb)
      tellPrimus: (cb)=>
        @_sendEvent('room-join', spark, room, cb)
    async.parallel asyncCalls, callback

  leftRoom: (spark, room, callback=noop)=>
    # console.log('left room', room)
    asyncCalls =
      logMinutes: (cb)->
        sendTalkTimeToKeen(spark, room, cb)
      tellPrimus: (cb)=>
        @_sendEvent('room-leave', spark, room, cb)
    async.parallel asyncCalls, callback

  leftRooms: (spark, rooms, callback=noop)=>
    leftRoom = (room, cb)=>
      @leftRoom(spark, room, cb)
    async.each rooms, leftRoom, callback

  _sendEvent: (action, spark, room, callback)->
    publicRoom = RoomManager.projectRoomNameWithoutProject(spark, room)
    data =
      action: action
      room: publicRoom
      sparkId: spark.id
      sparkUUID: spark.clientUUID
    data.identity = spark.identity if spark.identity
    @primus.room(room).except(spark.id).write(data)
    callback()
