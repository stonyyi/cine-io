Keen = require('keen.io')
config = Cine.config('variables/keen')

# Configure instance. Only projectId and writeKey are required to send data.
client = Keen.configure
  projectId: config.projectId
  writeKey: config.writeKey
  readKey: config.readKey
  masterKey: config.masterKey

noop = ->

sendToKeen = (collection, data, callback)->
  client.addEvent collection, data, callback

exports.userJoinedRoom = (projectId, room, sessionUUID, callback=noop)->
  data =
    projectId: projectId
    room: room
    sessionUUID: sessionUUID
    action: 'userJoinedRoom'
  sendToKeen 'peer-reporting', data, callback

exports.userLeftRoom = (projectId, room, sessionUUID, callback=noop)->
  data =
    projectId: projectId
    room: room
    sessionUUID: sessionUUID
    action: 'userLeftRoom'
  sendToKeen 'peer-reporting', data, callback
