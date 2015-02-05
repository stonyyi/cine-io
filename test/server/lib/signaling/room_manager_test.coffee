async = require('async')
RoomManager = Cine.server_lib('signaling/room_manager')
FakePrimus = Cine.require('test/helpers/fake_primus')
client = Cine.server_lib('redis_client')
debug = require('debug')('RoomManagerTest')
describe 'RoomManager', ->

  sparkForIndex = (i)->
    spark =
      clientUUID: "my-client-uuid-#{i}"
      projectId: "my-project-id"
      id: "the-spark-id-#{i}"
      signalingClient: "fake-client 0.0.1-#{i}"
      identity: "Thomas-#{i}"
      identityId: "54321-#{i}"


  UPDATED_AT_REDIS_KEY = "signaling:my-project-id:fun-room:updatedAt"
  MEMBERS_REDIS_KEY = "signaling:my-project-id:fun-room:members"

  beforeEach ->
    @spark = sparkForIndex(0)

  beforeEach ->
    @primus = new FakePrimus

  beforeEach ->
    @subject = new RoomManager(@primus)

  stubDate = ->
    Date.now.restore() if typeof Date.now.restore == 'function'
    @dateStub = sinon.stub(Date, 'now')
    @dateStub.onCall(0).returns(2000)
    @dateStub.onCall(1).returns(9000)
    @dateStub.onCall(2).returns(10000)
    @dateStub.onCall(3).returns(12000)

  describe '.projectRoomName', ->
    it 'returns the correct name', ->
      actual = RoomManager.projectRoomName(@spark, "this-room")
      expected = "my-project-id-this-room"
      expect(actual).to.equal(expected)

  describe '.projectRoomNameWithoutProject', ->
    it 'returns the name without the project id', ->
      actual = RoomManager.projectRoomNameWithoutProject(@spark, "my-project-id-this-room")
      expected = "this-room"
      expect(actual).to.equal(expected)

  describe '.projectRoomName -> .projectRoomNameWithoutProject -> .projectRoomName', ->
    it 'ensures we can go back and forth', ->
      withProjectId = RoomManager.projectRoomName(@spark, "this-room")
      expected = "my-project-id-this-room"
      expect(withProjectId).to.equal(expected)
      withoutProjectId = RoomManager.projectRoomNameWithoutProject(@spark, withProjectId)
      expect(withoutProjectId).to.equal('this-room')

  addSparksToRoom = (numberOfSparks, roomName, callback)->
    stubDate.call(this)
    joinRoom = (sparkId, cb)=>
      debug("sparkId", sparkId)
      spark = sparkForIndex(sparkId)
      @subject.joinedRoom spark, roomName, cb

    async.times numberOfSparks, joinRoom, callback


  describe '#joinedRoom', ->

    sendsUpdateToUsersInRoom = (memberCount, done)->
      addSparksToRoom.call this, memberCount, "fun-room", =>
        expect(@primus.room.callCount).to.equal(memberCount)
        args = @primus.room.firstCall.args
        scope = @primus.room.firstCall.returnValue
        expect(args).to.deep.equal(['fun-room'])
        expect(scope.except.calledOnce).to.be.true
        expect(scope.except.firstCall.args).to.deep.equal(['the-spark-id-0'])
        expect(scope.write.calledOnce).to.be.true
        expectedWriteArgs =
          action: 'room-join'
          room: 'fun-room'
          sparkId: 'the-spark-id-0'
          sparkUUID: 'my-client-uuid-0'
          identity: 'Thomas-0'
        expect(scope.write.firstCall.args).to.deep.equal([expectedWriteArgs])
        @dateStub.restore()
        done()

    describe 'first person in room', ->
      it 'updates redis about the entered time', (done)->
        addSparksToRoom.call this, 1, "fun-room", =>
          client.get UPDATED_AT_REDIS_KEY, (err, data)=>
            expect(err).to.be.null
            expect(data).to.equal('2000')
            @dateStub.restore()
            done()

      it 'updates redis about number of members', (done)->
        addSparksToRoom.call this, 1, "fun-room", =>
          client.smembers MEMBERS_REDIS_KEY, (err, data)=>
            expect(err).to.be.null
            expect(data).to.deep.equal(['my-client-uuid-0'])
            @dateStub.restore()
            done()

      it 'sends an update to all other users in room', (done)->
        sendsUpdateToUsersInRoom.call(this, 1, done)

    describe 'second person enters room', ->
      it 'updates the time the second person entered the room', (done)->
        addSparksToRoom.call this, 2, "fun-room", =>
          client.get UPDATED_AT_REDIS_KEY, (err, data)=>
            expect(err).to.be.null
            expect(data).to.equal('9000')
            @dateStub.restore()
            done()

      it 'updates redis about number of members', (done)->
        addSparksToRoom.call this, 2, "fun-room", =>
          client.smembers MEMBERS_REDIS_KEY, (err, data)=>
            expect(err).to.be.null
            expect(data.sort()).to.deep.equal(['my-client-uuid-0', 'my-client-uuid-1'])
            @dateStub.restore()
            done()

      it 'sends an update to all other users in room', (done)->
        sendsUpdateToUsersInRoom.call(this, 2, done)

    describe 'third person enters the room', ->

      beforeEach ->
        data =
          projectId: 'my-project-id'
          room: 'fun-room'
          action: 'userTalkedInRoom'
          talkTimeInMilliseconds: 2000
          userCount: 2
        @keenNock = requireFixture('nock/keen/send_event_success')('peer-minutes', data)

      it 'updates the time the second person entered the room', (done)->
        addSparksToRoom.call this, 3, "fun-room", =>
          client.get UPDATED_AT_REDIS_KEY, (err, data)=>
            expect(err).to.be.null
            expect(data).to.equal('10000')
            @dateStub.restore()
            done()

      it 'updates redis about number of members', (done)->
        addSparksToRoom.call this, 3, "fun-room", =>
          client.smembers MEMBERS_REDIS_KEY, (err, data)=>
            expect(err).to.be.null
            expect(data.sort()).to.deep.equal(['my-client-uuid-0', 'my-client-uuid-1', 'my-client-uuid-2'])
            @dateStub.restore()
            done()

      it 'sends an update to all other users in room', (done)->
        sendsUpdateToUsersInRoom.call(this, 3, done)

      it 'sends the talk time of the two users to keen', (done)->
        addSparksToRoom.call this, 3, "fun-room", =>
          expect(@keenNock.isDone()).to.be.true
          @dateStub.restore()
          done()

  describe '#leftRoom', ->
    removeSparkFromRoom = (sparkId, room, callback)->
      spark = sparkForIndex(sparkId)
      @subject.leftRoom spark, "fun-room", (err)->
        expect(err).to.be.undefined
        callback()

    sendsAnUpdateToPrimus = (callCount, done)->
      @subject.leftRoom @spark, "fun-room", (err)=>
        expect(err).to.be.undefined
        expect(@primus.room.callCount).to.equal(callCount)
        args = @primus.room.getCall(callCount-1).args
        scope = @primus.room.getCall(callCount-1).returnValue
        expect(args).to.deep.equal(['fun-room'])
        expect(scope.except.calledOnce).to.be.true
        expect(scope.except.firstCall.args).to.deep.equal(['the-spark-id-0'])
        expect(scope.write.calledOnce).to.be.true
        expectedWriteArgs =
          action: 'room-leave'
          room: 'fun-room'
          sparkId: 'the-spark-id-0'
          sparkUUID: 'my-client-uuid-0'
          identity: 'Thomas-0'
        expect(scope.write.firstCall.args).to.deep.equal([expectedWriteArgs])
        done()

    describe 'the last one in the room', ->
      it 'deletes redis updated key', (done)->
        addSparksToRoom.call this, 1, "fun-room", =>
          removeSparkFromRoom.call this, 0, "fun-room", =>
            client.get UPDATED_AT_REDIS_KEY, (err, data)=>
              expect(err).to.be.null
              expect(data).to.be.null
              @dateStub.restore()
              done()

      it 'deletes redis members key', (done)->
        addSparksToRoom.call this, 1, "fun-room", =>
          removeSparkFromRoom.call this, 0, "fun-room", =>
            client.get MEMBERS_REDIS_KEY, (err, data)=>
              expect(err).to.be.null
              expect(data).to.be.null
              @dateStub.restore()
              done()

      it 'sends an update to primus', (done)->
        sendsAnUpdateToPrimus.call this, 1, done

    describe 'the second to last one in the room', ->
      beforeEach ->
        data =
          projectId: 'my-project-id'
          room: 'fun-room'
          action: 'userTalkedInRoom'
          talkTimeInMilliseconds: 2000
          userCount: 2
        @keenNockForLeave = requireFixture('nock/keen/send_event_success')('peer-minutes', data)

      it 'updates redis updated key', (done)->
        addSparksToRoom.call this, 2, "fun-room", =>
          removeSparkFromRoom.call this, 0, "fun-room", =>
            client.get UPDATED_AT_REDIS_KEY, (err, data)=>
              expect(err).to.be.null
              expect(data).to.equal('10000')
              @dateStub.restore()
              done()

      it 'deletes redis members key', (done)->
        addSparksToRoom.call this, 2, "fun-room", =>
          removeSparkFromRoom.call this, 0, "fun-room", =>
            client.smembers MEMBERS_REDIS_KEY, (err, data)=>
              expect(err).to.be.null
              expect(data.sort()).to.deep.equal(['my-client-uuid-1'])
              @dateStub.restore()
              done()

      it 'sends an update to primus', (done)->
        addSparksToRoom.call this, 2, "fun-room", =>
          sendsAnUpdateToPrimus.call this, 3, done

      it 'sends the talk time of the two users to keen', (done)->
        addSparksToRoom.call this, 2, "fun-room", =>
          removeSparkFromRoom.call this, 1, "fun-room", =>
            expect(@keenNockForLeave.isDone()).to.be.true
            @dateStub.restore()
            done()

    describe 'the third person leaves, resulting in a room of 2', ->
      beforeEach ->
        data =
          projectId: 'my-project-id'
          room: 'fun-room'
          action: 'userTalkedInRoom'
          talkTimeInMilliseconds: 2000
          userCount: 2
        @keenNockForJoin = requireFixture('nock/keen/send_event_success')('peer-minutes', data)

      beforeEach ->
        data =
          projectId: 'my-project-id'
          room: 'fun-room'
          action: 'userTalkedInRoom'
          talkTimeInMilliseconds: 6000
          userCount: 3
        @keenNockForLeave = requireFixture('nock/keen/send_event_success')('peer-minutes', data)

      it 'updates redis updated key', (done)->
        addSparksToRoom.call this, 3, "fun-room", =>
          removeSparkFromRoom.call this, 0, "fun-room", =>
            client.get UPDATED_AT_REDIS_KEY, (err, data)=>
              expect(err).to.be.null
              expect(data).to.equal('12000')
              @dateStub.restore()
              done()

      it 'deletes redis members key', (done)->
        addSparksToRoom.call this, 3, "fun-room", =>
          removeSparkFromRoom.call this, 1, "fun-room", =>
            client.smembers MEMBERS_REDIS_KEY, (err, data)=>
              expect(err).to.be.null
              expect(data.sort()).to.deep.equal(['my-client-uuid-0', 'my-client-uuid-2'])
              @dateStub.restore()
              done()

      it 'sends an update to primus', (done)->
        addSparksToRoom.call this, 3, "fun-room", =>
          sendsAnUpdateToPrimus.call this, 4, done

      it 'sends the talk time of the three users to keen', (done)->
        addSparksToRoom.call this, 3, "fun-room", =>
          expect(@keenNockForJoin.isDone()).to.be.true
          removeSparkFromRoom.call this, 1, "fun-room", =>
            expect(@keenNockForLeave.isDone()).to.be.true
            @dateStub.restore()
            done()

  describe '#leftRooms', ->
    it 'calls leave room on all rooms', (done)->
      sinon.spy @subject, 'leftRoom'
      @subject.leftRooms @spark, ["fun-room1", "fun-room2"], (err)=>
        expect(err).to.be.undefined
        expect(@subject.leftRoom.calledTwice).to.be.true
        expect(@subject.leftRoom.firstCall.args[0]).to.equal(@spark)
        expect(@subject.leftRoom.firstCall.args[1]).to.equal("fun-room1")
        expect(@subject.leftRoom.firstCall.args[2]).to.be.a("function")
        expect(@subject.leftRoom.secondCall.args[0]).to.equal(@spark)
        expect(@subject.leftRoom.secondCall.args[1]).to.equal("fun-room2")
        expect(@subject.leftRoom.secondCall.args[2]).to.be.a("function")
        @subject.leftRoom.restore()
        done()
