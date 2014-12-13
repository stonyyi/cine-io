logEventInKeen = Cine.server_lib('reporting/peer/log_event_in_keen')

describe 'logEventInKeen', ->
  describe 'userJoinedRoom', ->
    beforeEach ->
      data =
        projectId: "the proj id"
        room: "the room name"
        sessionUUID: "client session id"
        action: "userJoinedRoom"
      data2 =
        projectId: "the proj id"
        room: "the room name"
        sessionUUID: "client session id"
        action: "userJoinedRoom"
        more: 'data'
      @keenNock = requireFixture('nock/keen/send_event_success')('peer-reporting', data)
      @keenNock2 = requireFixture('nock/keen/send_event_success')('peer-reporting', data2)

    it 'sends an event to keen.io', (done)->
      logEventInKeen.userJoinedRoom "the proj id", 'the room name', 'client session id', (err)=>
        expect(err).to.be.null
        expect(@keenNock.isDone()).to.be.true
        done()

    it 'sends extra data keen.io', (done)->
      logEventInKeen.userJoinedRoom "the proj id", 'the room name', 'client session id', more: 'data', (err)=>
        expect(err).to.be.null
        expect(@keenNock2.isDone()).to.be.true
        done()

  describe 'userLeftRoom', ->
    beforeEach ->
      data =
        projectId: "the proj id"
        room: "the room name"
        sessionUUID: "client session id"
        action: "userLeftRoom"
      data2 =
        projectId: "the proj id"
        room: "the room name"
        sessionUUID: "client session id"
        action: "userLeftRoom"
        more: 'data'
      @keenNock = requireFixture('nock/keen/send_event_success')('peer-reporting', data)
      @keenNock2 = requireFixture('nock/keen/send_event_success')('peer-reporting', data2)

    it 'sends an event to keen.io', (done)->
      logEventInKeen.userLeftRoom "the proj id", 'the room name', 'client session id', (err)=>
        expect(err).to.be.null
        expect(@keenNock.isDone()).to.be.true
        done()

    it 'sends extra data keen.io', (done)->
      logEventInKeen.userLeftRoom "the proj id", 'the room name', 'client session id', more: 'data', (err)=>
        expect(err).to.be.null
        expect(@keenNock2.isDone()).to.be.true
        done()

# Keen = require('keen.io')
# config = Cine.config('variables/keen')

# # Configure instance. Only projectId and writeKey are required to send data.
# client = Keen.configure
#   projectId: config.projectId
#   writeKey: config.writeKey
#   readKey: config.readKey
#   masterKey: config.masterKey

# noop = ->

# sendToKeen = (collection, data, callback)->
#   client.addEvent collection, data, callback

# exports.userJoinedRoom = (projectId, room, sessionUUID, callback=noop)->
#   data =
#     projectId: projectId
#     room: room
#     sessionUUID: sessionUUID
#     action: 'userJoinedRoom'
#   sendToKeen 'peer-reporting', data, callback

# exports.userLeftRoom = (projectId, room, sessionUUID, callback=noop)->
#   data =
#     projectId: projectId
#     room: room
#     sessionUUID: sessionUUID
#     action: 'userLeftRoom'
#   sendToKeen 'peer-reporting', data, callback
