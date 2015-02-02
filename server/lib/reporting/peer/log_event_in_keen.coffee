_ = require('underscore')
client = Cine.server_lib('keen_client')

noop = ->

sendToKeen = (collection, data, callback)->
  # console.log("sending to keen", collection, data)
  client.addEvent collection, data, callback

exports.userTalkedInRoom = (projectId, room, sessionUUID, extraData={}, callback=noop)->
  if typeof extraData == 'function'
    callback = extraData
    extraData = {}
  data =
    projectId: projectId
    room: room
    sessionUUID: sessionUUID
    action: 'userTalkedInRoom'
  _.extend(data, extraData)
  sendToKeen 'peer-minutes', data, callback
