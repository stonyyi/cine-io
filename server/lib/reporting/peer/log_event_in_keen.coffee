_ = require('underscore')
client = Cine.server_lib('keen_client')

noop = ->

sendToKeen = (collection, data, callback)->
  client.addEvent collection, data, callback

exports.userJoinedRoom = (projectId, room, sessionUUID, extraData={}, callback=noop)->
  if typeof extraData == 'function'
    callback = extraData
    extraData = {}
  data =
    projectId: projectId
    room: room
    sessionUUID: sessionUUID
    action: 'userJoinedRoom'
  _.extend(data, extraData)
  sendToKeen 'peer-reporting', data, callback

exports.userLeftRoom = (projectId, room, sessionUUID, extraData={}, callback=noop)->
  if typeof extraData == 'function'
    callback = extraData
    extraData = {}
  data =
    projectId: projectId
    room: room
    sessionUUID: sessionUUID
    action: 'userLeftRoom'
  _.extend(data, extraData)
  sendToKeen 'peer-reporting', data, callback
