logEventInKeen = Cine.server_lib('reporting/peer/log_event_in_keen')

describe 'logEventInKeen', ->
  describe 'userJoinedRoom', ->
    beforeEach ->
      data =
        projectId: "the proj id"
        room: "the room name"
        sessionUUID: "client session id"
        action: "userTalkedInRoom"
      data2 =
        projectId: "the proj id"
        room: "the room name"
        sessionUUID: "client session id"
        action: "userTalkedInRoom"
        more: 'data'
      @keenNock = requireFixture('nock/keen/send_event_success')('peer-minutes', data)
      @keenNock2 = requireFixture('nock/keen/send_event_success')('peer-minutes', data2)

    it 'sends an event to keen.io', (done)->
      logEventInKeen.userTalkedInRoom "the proj id", 'the room name', 'client session id', (err)=>
        expect(err).to.be.null
        expect(@keenNock.isDone()).to.be.true
        done()

    it 'sends extra data keen.io', (done)->
      logEventInKeen.userTalkedInRoom "the proj id", 'the room name', 'client session id', more: 'data', (err)=>
        expect(err).to.be.null
        expect(@keenNock2.isDone()).to.be.true
        done()
