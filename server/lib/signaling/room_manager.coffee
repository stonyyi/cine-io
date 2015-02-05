async = require('async')
logEventInKeen = Cine.server_lib('reporting/peer/log_event_in_keen')
redisClient = Cine.server_lib('redis_client')
debug = require('debug')('cine:RoomManager')
noop = ->

MEMBERS_FIELD = 'members'
UPDATED_FIELD = 'updatedAt'

sparkRoomKey = (spark, room, type)->
  "signaling:#{spark.projectId}:#{room}:#{type}"

logJoinInRedis = (spark, room, callback)->
  newTime = Date.now()
  updatedKey = sparkRoomKey(spark, room, UPDATED_FIELD)
  membersKey = sparkRoomKey(spark, room, MEMBERS_FIELD)
  debug("adding member", membersKey, spark.clientUUID)
  scope = redisClient.multi()
    .get(updatedKey) #get last updated
    .set(updatedKey, newTime) #set new time
    .scard(membersKey) # get number of members in set
    .sadd(membersKey, spark.clientUUID) # add member to set (returns 1 for added, and 0 for not added)
  scope.exec (err, replies)->
    debug("updated redis", err, replies)
    return callback(err) if err
    lastUpdatedTime = replies[n=0]
    didUpdateNewTime = replies[++n]
    totalNumberOfMembersBeforeAdd = replies[++n]
    didAddNewMember = replies[++n]
    totalMembersInRoom = totalNumberOfMembersBeforeAdd + didAddNewMember #didAddNewMember is either 0 or 1
    debug("total members in room", membersKey, totalMembersInRoom, totalNumberOfMembersBeforeAdd)
    return callback() if totalMembersInRoom <= 2 #if there are two people in the room, do not send info to keen
    debug("total time", newTime, lastUpdatedTime)
    totalTalkTimeBeforeNewClient = (newTime - lastUpdatedTime) * totalNumberOfMembersBeforeAdd

    sendTalkTimeToKeen(totalTalkTimeBeforeNewClient, spark.projectId, room, callback)

logLeaveInRedis = (spark, room, callback)->
  newTime = Date.now()
  updatedKey = sparkRoomKey(spark, room, UPDATED_FIELD)
  membersKey = sparkRoomKey(spark, room, MEMBERS_FIELD)
  debug("removing member", membersKey, spark.clientUUID)
  scope = redisClient.multi()
    .get(updatedKey) #get last updated
    .set(updatedKey, newTime) #set new time
    .scard(membersKey) # get number of members in set
    .srem(membersKey, spark.clientUUID) # remove member to set (returns 1 for removed, and 0 for not removed)
  scope.exec (err, replies)->
    debug("updated redis", err, replies)
    return callback(err) if err
    lastUpdatedTime = replies[n=0]
    didUpdateNewTime = replies[++n]
    totalNumberOfMembersBeforeRemove = replies[++n]
    didRemoveOldMember = replies[++n]
    totalMembersInRoom = totalNumberOfMembersBeforeRemove - didRemoveOldMember #didRemoveOldMember is either 0 or 1
    debug("total members in room", membersKey, totalMembersInRoom, totalNumberOfMembersBeforeRemove)
    return redisClient.del(updatedKey, membersKey, callback) if  totalMembersInRoom == 0
    return callback() if  totalMembersInRoom == 1 && !didRemoveOldMember
    debug("total time", newTime, lastUpdatedTime)
    totalTalkTimeBeforeNewClient = (newTime - lastUpdatedTime) * totalNumberOfMembersBeforeRemove

    sendTalkTimeToKeen(totalTalkTimeBeforeNewClient, spark.projectId, room, callback)


sendTalkTimeToKeen = (talkTimeInMilliseconds, projectId, room, callback)->
  data =
    talkTimeInMilliseconds: talkTimeInMilliseconds
  # console.log("SENDING EVENT", extraData)
  logEventInKeen.userTalkedInRoom projectId, room, data, callback

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
        logJoinInRedis(spark, room, cb)
      tellPrimus: (cb)=>
        @_sendEvent('room-join', spark, room, cb)
    async.parallel asyncCalls, callback

  leftRoom: (spark, room, callback=noop)=>
    # console.log('left room', room)
    asyncCalls =
      logMinutes: (cb)->
        logLeaveInRedis(spark, room, cb)
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
