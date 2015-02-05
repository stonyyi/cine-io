_ = require('underscore')
client = Cine.server_lib('keen_client')
debug = require('debug')('cine:log_event_in_keen')

noop = ->

KEEN_COLLECTION = 'peer-minutes'

sendToKeen = (collection, data, callback)->
  # console.log("sending to keen", collection, data)
  client.addEvent collection, data, callback

exports.userTalkedInRoom = (projectId, room, extraData={}, callback=noop)->
  if typeof extraData == 'function'
    callback = extraData
    extraData = {}
  data =
    projectId: projectId
    room: room
    action: 'userTalkedInRoom'
  _.extend(data, extraData)
  debug("sending to keen", KEEN_COLLECTION, data)
  sendToKeen KEEN_COLLECTION, data, callback
