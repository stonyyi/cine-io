_ = require('underscore')
async = require('async')
Primus = Cine.require('apps/signaling/node_modules/primus')
Socket = Primus.createSocket({transformer: 'sockjs', parser: 'json'})
portfinder = Cine.require('apps/signaling/node_modules/portfinder')
Project = Cine.server_model('project')
PeerIdentity = Cine.server_model('peer_identity')
cp = require('child_process')

describe 'socket calls', ->
  @timeout(5000)

  before (done)->
    portfinder.getPort (err, port)=>
      return done(err) if err
      console.log("Found port", port)
      @availablePort = port
      newEnv = _.clone(process.env)
      newEnv.PORT = @availablePort
      newEnv.RUN_AS = "signaling"
      newEnv.NO_SPAWN = true
      @child = cp.fork(Cine.path('server.coffee'), env: newEnv)
      @child.on 'message', (m)->
        done() if m == 'listening'

  after ->
    @child.kill()

  newClient = (callback)->
    c = new Socket("http://127.0.0.1:#{@availablePort}/")
    c.on 'open', callback

  beforeEach (done)->
    @client = newClient.call(this, done)

  afterEach ->
    @client.end()

  it 'recieves rtc-servers right away', (done)->
    @client.on 'data', (data)->
      expect(data.action).to.equal('rtc-servers')
      expect(data.data).to.have.length(1)
      expect(data.data[0].url.indexOf("stun:")).to.equal(0)
      done()

  describe 'conversations', ->
    beforeEach (done)->
      @project = new Project(publicKey: 'this-is-a-real-api-key', secretKey: 'super-secret-key')
      @project.save done

    beforeEach (done)->
      @otherClient = newClient.call(this, done)

    afterEach ->
      @otherClient.end()

    joinTestRoom = (client, callback)->
      client.write action: 'room-join', room: 'test-room'
      if callback
        client.on 'data', (data)->
          return unless data.source == 'room-join'
          callback()

    leaveTestRoom = (client)->
      client.write action: 'room-leave', room: 'test-room'

    describe 'auth', ->

      it 'closes the connection if the publicKey is wrong', (done)->
        # poor man's ensuring both events fire
        gotData = false
        gotEnd = false
        @client.on 'data', (data)->
          gotData = true
          expect(data).to.deep.equal(action: 'error', error: 'INVALID_PUBLIC_KEY', message: 'invalid publicKey: INVALID_PUBLIC_KEY provided')
          done() if gotEnd
        @client.on 'end', (data)->
          gotEnd = true
          done() if gotData
        @client.write action: 'auth', publicKey: 'INVALID_PUBLIC_KEY'

      it 'keeps the connection open if the publicKey is correct', (done)->
        @client.on 'data', (data)->
          expect(data).to.deep.equal(action: 'ack', source: 'auth')
          done()
        @client.write action: 'auth', publicKey: 'this-is-a-real-api-key'

    describe 'rooms', ->
      beforeEach ->
        @client.write action: 'auth', publicKey: 'this-is-a-real-api-key'
        @otherClient.write action: 'auth', publicKey: 'this-is-a-real-api-key'

      beforeEach (done)->
        joinTestRoom @client, done

      it 'gets a new member', (done)->
        @client.on 'data', (data)->
          return unless data.action == 'room-join'
          expect(data.room).to.equal('test-room')
          expect(data.sparkId).to.have.length(36)
          done()

        joinTestRoom @otherClient

      it 'passes along an announce', (done)->
        @client.on 'data', (data)=>
          return unless data.action == 'room-join'
          expect(data.room).to.equal('test-room')
          expect(data.sparkId).to.have.length(36)
          @client.write(action: 'room-announce', sparkId: data.sparkId)

        @otherClient.on 'data', (data)->
          return unless data.action == 'room-announce'
          expect(data.sparkId).to.have.length(36)
          done()

        joinTestRoom @otherClient

      it 'handles leave', (done)->
        otherClientSparkId = null
        @client.on 'data', (data)=>
          switch data.action
            when 'room-join'
              otherClientSparkId = data.sparkId
              leaveTestRoom @otherClient
            when 'room-leave'
              expect(data.sparkId).to.equal(otherClientSparkId)
              expect(data.room).to.equal('test-room')
              done()

        joinTestRoom @otherClient

      it 'passes along a goodbye', (done)->
        @client.on 'data', (data)=>
          if data.action == 'room-join'
            expect(data.room).to.equal('test-room')
            expect(data.sparkId).to.have.length(36)
            leaveTestRoom @client
          if data.action == 'room-goodbye'
            done()

        @otherClient.on 'data', (data)=>
          return unless data.action == 'room-leave'
          expect(data.sparkId).to.have.length(36)
          @otherClient.write(action: 'room-goodbye', sparkId: data.sparkId)

        joinTestRoom @otherClient

    describe 'PeerConnection conversation', ->

      beforeEach ->
        @client.write action: 'auth', publicKey: 'this-is-a-real-api-key'
        @otherClient.write action: 'auth', publicKey: 'this-is-a-real-api-key'

      beforeEach (done)->
        joinTestRoom @client, done

      it 'can send ice servers', (done)->
        @client.on 'data', (data)=>
          return unless data.action == 'room-join'
          otherClientSparkId = data.sparkId
          @client.write action: 'rtc-ice', source: "test-client", candidate: 'fake candidate', sparkId: otherClientSparkId

        @otherClient.on 'data', (data)->
          return unless data.action == 'rtc-ice'
          expect(data.candidate).to.equal('fake candidate')
          done()

        joinTestRoom @otherClient

      it 'can send offers', (done)->
        @client.on 'data', (data)=>
          return unless data.action == 'room-join'
          otherClientSparkId = data.sparkId
          @client.write action: 'rtc-offer', source: "test-client", offer: 'fake offer', sparkId: otherClientSparkId

        @otherClient.on 'data', (data)->
          return unless data.action == 'rtc-offer'
          expect(data.offer).to.equal('fake offer')
          done()

        joinTestRoom @otherClient

      it 'can send answers', (done)->
        @client.on 'data', (data)=>
          return unless data.action == 'room-join'
          otherClientSparkId = data.sparkId
          @client.write action: 'rtc-answer', source: "test-client", answer: 'fake answer', sparkId: otherClientSparkId

        @otherClient.on 'data', (data)->
          return unless data.action == 'rtc-answer'
          expect(data.answer).to.equal('fake answer')
          done()

        joinTestRoom @otherClient

    describe 'point to point calling', ->

      beforeEach ->
        @client.write action: 'auth', publicKey: 'this-is-a-real-api-key'
        @otherClient.write action: 'auth', publicKey: 'this-is-a-real-api-key'

      identify = (client, name, timestamp, signature)->
        client.write action: 'identify', client: 'test-client', identity: name, timestamp: timestamp, signature: signature, publicKey: 'this-is-a-real-api-key'

      ensurePeerConnecitonMade = (numberOfIdentities, done)->
        identitySet = false
        testFunction = -> identitySet
        checkFunction = (callback)->
          PeerIdentity.findOne identity: 'meee', (err, identity)->
            return callback(err) if err
            return async.nextTick callback unless identity
            identitySet = identity.currentConnections.length == numberOfIdentities
            if numberOfIdentities > 0
              expect(identity.currentConnections[0].sparkId).to.have.length(36)
              expect(identity.currentConnections[0].client).to.equal('test-client')
            callback()

        async.until testFunction, checkFunction, (err)->
          done(err)

      describe 'identify', ->
        it 'requires a valid signature based on the secret key', (done)->
          @client.on 'data', (data)->
            return unless data.action == 'error'
            expect(data.error).to.equal('INVALID_SIGNATURE')
            expect(data.message).to.equal("invalid signature: invalid-signature-dude provided")
            done()
          identify @client, 'meee', '1418075572', 'invalid-signature-dude'

        it 'saves the spark id in mongo on identify', (done)->
          identify @client, 'meee', '1418075572', '41c3c037d56a51cb9dd4389592bd5115f3fa1237'
          ensurePeerConnecitonMade 1, done

        it 'removes the current connection on disconnect', (done)->
          identify @client, 'meee', '1418075572', '41c3c037d56a51cb9dd4389592bd5115f3fa1237'
          ensurePeerConnecitonMade 1, (err)=>
            return done(err) if err
            @client.end()
            ensurePeerConnecitonMade 0, done

      describe 'call', ->
        beforeEach (done)->
          identify @client, 'meee', '1418075572', '41c3c037d56a51cb9dd4389592bd5115f3fa1237'
          identify @otherClient, 'other', '1418075572', '41c3c037d56a51cb9dd4389592bd5115f3fa1237'
          setTimeout done, 100

        it 'sends the other client a room', (done)->
          @client.on 'data', (data)->
            return unless data.action == 'call'
            expect(data.room).to.have.length(64)
            expect(data.sparkId).to.have.length(36)
            done()
          ensurePeerConnecitonMade 1, (err)=>
            return done(err) if err
            @otherClient.write action: 'call', otheridentity: 'meee', publicKey: 'this-is-a-real-api-key'

      describe 'reject', ->
        beforeEach (done)->
          identify @client, 'meee', '1418075572', '41c3c037d56a51cb9dd4389592bd5115f3fa1237'
          identify @otherClient, 'other', '1418075572', '41c3c037d56a51cb9dd4389592bd5115f3fa1237'
          setTimeout done, 100

        it 'sends the other client a rejection', (done)->
          room = null
          @client.on 'data', (data)=>
            return unless data.action == 'call'
            room = data.room
            @client.write action: 'call-reject', room: data.room, identity: "meee", publicKey: "this-is-a-real-api-key"

          @otherClient.on 'data', (data)->
            return unless data.action == 'call-reject'
            expect(data.identity).to.equal('meee')
            expect(data.room).to.be.ok
            expect(data.room).to.equal(room)
            done()
          ensurePeerConnecitonMade 1, (err)=>
            return done(err) if err
            @otherClient.write action: 'call', otheridentity: 'meee', publicKey: 'this-is-a-real-api-key'
