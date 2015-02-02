RoomManager = Cine.server_lib('signaling/room_manager')
FakePrimus = Cine.require('test/helpers/fake_primus')
client = Cine.server_lib('redis_client')

describe 'RoomManager', ->
  beforeEach ->
    @spark =
      clientUUID: 'my-client-uuid'
      projectId: 'my-project-id'
      id: 'the-spark-id'
      signalingClient: 'fake-client 0.0.1'
      identity: 'Thomas'
      identityId: '54321'
  beforeEach ->
    @primus = new FakePrimus
  beforeEach ->
    @subject = new RoomManager(@primus)

  stubDate = ->
    @dateStub = sinon.stub(Date, 'now')
    @dateStub.onCall(0).returns(2000)
    @dateStub.onCall(1).returns(9000)

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

  describe '#joinedRoom', ->

    afterEach ->
      @dateStub.restore()

    it 'logs an event in redis', (done)->
      stubDate.call(this) #need to do this here because mocha calls Date.now before a test
      @subject.joinedRoom @spark, "fun-room", (err)=>
        expect(err).to.be.undefined
        redisKey = "signaling:my-client-uuid-fun-room-join"
        client.get redisKey, (err, data)=>
          expect(err).to.be.null
          expect(data).to.equal("2000")
          expect(@dateStub.calledOnce).to.be.true
          done()
    it 'does not overwrite an existing value in redis', (done)->
      stubDate.call(this) #need to do this here because mocha calls Date.now before a test
      @subject.joinedRoom @spark, "fun-room", (err)=>
        expect(err).to.be.undefined
        @subject.joinedRoom @spark, "fun-room", (err)=>
          expect(err).to.be.undefined
          redisKey = "signaling:my-client-uuid-fun-room-join"
          client.get redisKey, (err, data)=>
            expect(err).to.be.null
            expect(data).to.equal("2000")
            expect(@dateStub.calledTwice).to.be.true
            done()

    it 'sends an update to all other people in primus', (done)->
      @subject.joinedRoom @spark, "fun-room", (err)=>
        expect(err).to.be.undefined
        expect(@primus.room.calledOnce).to.be.true
        args = @primus.room.firstCall.args
        scope = @primus.room.firstCall.returnValue
        expect(args).to.deep.equal(['fun-room'])
        expect(scope.except.calledOnce).to.be.true
        expect(scope.except.firstCall.args).to.deep.equal(['the-spark-id'])
        expect(scope.write.calledOnce).to.be.true
        expectedWriteArgs =
          action: 'room-join'
          room: 'fun-room'
          sparkId: 'the-spark-id'
          sparkUUID: 'my-client-uuid'
          identity: 'Thomas'
        expect(scope.write.firstCall.args).to.deep.equal([expectedWriteArgs])
        done()

  describe '#leftRoom', ->
    sendsAnUpdateToPrimus = (callCount, done)->
      @subject.leftRoom @spark, "fun-room", (err)=>
        expect(err).to.be.undefined
        expect(@primus.room.callCount).to.equal(callCount)
        args = @primus.room.getCall(callCount-1).args
        scope = @primus.room.getCall(callCount-1).returnValue
        expect(args).to.deep.equal(['fun-room'])
        expect(scope.except.calledOnce).to.be.true
        expect(scope.except.firstCall.args).to.deep.equal(['the-spark-id'])
        expect(scope.write.calledOnce).to.be.true
        expectedWriteArgs =
          action: 'room-leave'
          room: 'fun-room'
          sparkId: 'the-spark-id'
          sparkUUID: 'my-client-uuid'
          identity: 'Thomas'
        expect(scope.write.firstCall.args).to.deep.equal([expectedWriteArgs])
        done()

    describe 'without a previous join', ->
      it 'does not error and sends an update to all other people in primus', (done)->
        sendsAnUpdateToPrimus.call(this, 1, done)

    describe 'with a previous join', ->
      afterEach ->
        @dateStub.restore()

      beforeEach ->
        data =
          projectId: 'my-project-id'
          room: 'fun-room'
          sessionUUID: 'my-client-uuid'
          action: 'userTalkedInRoom'
          signalingClient: 'fake-client 0.0.1'
          talkTimeInMilliseconds: 7000
          identity: 'Thomas'
          identityId: '54321'
        @keenNock = requireFixture('nock/keen/send_event_success')('peer-minutes', data)

      joinRoom = (done)->
        stubDate.call(this) #need to do this here because mocha calls Date.now before a test
        @subject.joinedRoom @spark, "fun-room", (err)->
          expect(err).to.be.undefined
          done()

      it 'logs the event in keen.io', (done)->
        joinRoom.call this, =>
          @subject.leftRoom @spark, "fun-room", (err)=>
            expect(err).to.be.undefined
            expect(@keenNock.isDone()).to.be.true
            done()

      it 'deletes the joined time in redis', (done)->
        redisKey = "signaling:my-client-uuid-fun-room-join"
        joinRoom.call this, =>
          client.get redisKey, (err, data)=>
            expect(err).to.be.null
            expect(data).to.equal("2000")
            @subject.leftRoom @spark, "fun-room", (err)->
              expect(err).to.be.undefined
              client.get redisKey, (err, data)->
                expect(err).to.be.null
                expect(data).to.be.null
                done()

      it 'sends an update to all other people in primus', (done)->
        joinRoom.call this, =>
          sendsAnUpdateToPrimus.call(this, 2, done)

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
        done()
