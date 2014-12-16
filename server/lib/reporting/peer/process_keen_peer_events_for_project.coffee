_ = require('underscore')

dateSort = (event)->
  event.keen.timestamp

projectRoomNameWithoutProject = (projectId, roomName)->
  regex = new RegExp("^#{projectId}-")
  roomName.replace(regex, '')

class SessionExperience
  constructor: (@projectId, @events=[], @timeInRooms={})->
  addUpTime = (accum, timeInRoom, roomName)->
    accum + timeInRoom
  addEvent: (event)->
    @events.push event
  _addTimeToRooms: (room, time)->
    @timeInRooms[room] ||= 0
    @timeInRooms[room] += time
  _totalTime: ->
    _.inject(@timeInRooms, addUpTime, 0)
  _logResult: (identity)->
    for room, time of @timeInRooms
      console.log("", identity, 'talked for', time / 1000, 'seconds in', projectRoomNameWithoutProject(@projectId, room))
  _calculateJoinAndLeaveTimes: ->
    eventsInOrder = _.sortBy @events, dateSort
    # console.log("Events in order", eventsInOrder)
    timeInRoom = {} # {roomName: startTime (Date), …}
    for event in eventsInOrder
      startTime = timeInRoom[event.room]
      switch event.action
        when 'userJoinedRoom'
          if startTime == undefined # first time we joined this room
            timeInRoom[event.room] = new Date(event.keen.timestamp)
          else
            # they joined same room twice in a row before leaving
            # this probably happened because the signaling server restarted
            # and the new connections joined the room
            # but the sessionUUID would stay the same
        when 'userLeftRoom'
          if startTime == undefined
            console.error("Left room before joined")
          else
            endTime = new Date(event.keen.timestamp)
            @_addTimeToRooms(event.room, endTime - startTime)
            delete timeInRoom[event.room]

    if !_.isEmpty(timeInRoom)
      console.error("userJoinedRoom in some rooms but never left")

  calculateTotalTimeInMs: ->
    @_calculateJoinAndLeaveTimes()
    # @_logResult(@events[0].identity)
    return @_totalTime()

class Aggregator
  constructor: (@projectId, @sessionExperiences={})->

  addUpTime = (accum, sessionExperience, sessionUUID)->
    sessionTotal = sessionExperience.calculateTotalTimeInMs()
    accum += sessionTotal

  addEvent: (event)=>
    @_getSessionExperienceFromEvent(event).addEvent(event)

  _getSessionExperienceFromEvent: (event)->
    @sessionExperiences[event.sessionUUID] ||= new SessionExperience(@projectId)

  calculateTotalTimeInMs: ->
    _.inject @sessionExperiences, addUpTime, 0

module.exports = (projectId, events, callback)->
  agg = new Aggregator(projectId)
  agg.addEvent(event) for event in events
  totalTimeInMs = agg.calculateTotalTimeInMs()
  process.nextTick ->
    callback(null, totalTimeInMs)
