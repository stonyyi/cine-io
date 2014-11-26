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
      @child = cp.fork(Cine.path('server.coffee'), env: {PORT: @availablePort, NODE_ENV: process.env.NODE_ENV, RUN_AS: "signaling", NO_SPAWN: true})
      @child.on 'message', (m)->
        done() if m == 'listening'

  after ->
    @child.kill()

  newClient = ->
    new Socket("http://127.0.0.1:#{@availablePort}/")

  beforeEach ->
    @client = newClient.call(this)

  afterEach ->
    @client.end()

  it 'connects', (done)->
    @client.on 'open', ->
      done()

  it 'recieves allservers right away', (done)->
    @client.on 'data', (data)->
      expect(data.action).to.equal('allservers')
      expect(data.data).to.have.length(9)
      expect(data.data[0].url.indexOf("stun:")).to.equal(0)
      done()


  describe 'conversations', ->
    joinTestRoom = (client)->
      client.write action: 'join', room: 'test-room'

    leaveTestRoom = (client)->
      client.write action: 'leave', room: 'test-room'

    beforeEach ->
      @otherClient = newClient.call(this)
      joinTestRoom @client

    afterEach ->
      @otherClient.end()

    describe 'rooms', ->

      it 'gets a new member', (done)->
        @client.on 'data', (data)->
          return unless data.action == 'member'
          expect(data.room).to.equal('test-room')
          expect(data.sparkId).to.have.length(36)
          done()

        joinTestRoom @otherClient

      it 'handles leave', (done)->
        otherClientSparkId = null
        @client.on 'data', (data)=>
          switch data.action
            when 'member'
              otherClientSparkId = data.sparkId
              leaveTestRoom @otherClient
            when 'leave'
              expect(data.sparkId).to.equal(otherClientSparkId)
              expect(data.room).to.equal('test-room')
              done()

        joinTestRoom @otherClient

    describe 'PeerConnection conversation', ->

      it 'can send ice servers', (done)->
        @client.on 'data', (data)=>
          return unless data.action == 'member'
          otherClientSparkId = data.sparkId
          @client.write action: 'ice', source: "test-client", candidate: 'fake candidate', sparkId: otherClientSparkId

        @otherClient.on 'data', (data)->
          return unless data.action == 'ice'
          expect(data.candidate).to.equal('fake candidate')
          done()

        joinTestRoom @otherClient

      it 'can send offers', (done)->
        @client.on 'data', (data)=>
          return unless data.action == 'member'
          otherClientSparkId = data.sparkId
          @client.write action: 'offer', source: "test-client", offer: 'fake offer', sparkId: otherClientSparkId

        @otherClient.on 'data', (data)->
          return unless data.action == 'offer'
          expect(data.offer).to.equal('fake offer')
          done()

        joinTestRoom @otherClient

      it 'can send answers', (done)->
        @client.on 'data', (data)=>
          return unless data.action == 'member'
          otherClientSparkId = data.sparkId
          @client.write action: 'answer', source: "test-client", answer: 'fake answer', sparkId: otherClientSparkId

        @otherClient.on 'data', (data)->
          return unless data.action == 'answer'
          expect(data.answer).to.equal('fake answer')
          done()

        joinTestRoom @otherClient

    describe 'point to point calling', ->

      beforeEach (done)->
        @project = new Project(publicKey: 'this-is-a-real-api-key')
        @project.save done

      identify = (client, name, publicKey)->
        client.write action: 'identify', client: 'test-client', identity: name, publicKey: publicKey

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
        it 'requires an project based on an publicKey', (done)->
          @client.on 'data', (data)->
            return unless data.action == 'error'
            expect(data.error).to.equal('INVALID_PUBLIC_KEY')
            expect(data.message).to.equal("invalid publicKey: invalid-key-dude provided")
            done()
          identify @client, 'meee', 'invalid-key-dude'

        it 'saves the spark id in mongo on identify', (done)->
          identify @client, 'meee', 'this-is-a-real-api-key'
          ensurePeerConnecitonMade 1, done

        it 'removes the current connection on disconnect', (done)->
          identify @client, 'meee', 'this-is-a-real-api-key'
          ensurePeerConnecitonMade 1, (err)=>
            return done(err) if err
            @client.end()
            ensurePeerConnecitonMade 0, done

      describe 'call', ->
        beforeEach (done)->
          identify @client, 'meee', 'this-is-a-real-api-key'
          identify @otherClient, 'other', 'this-is-a-real-api-key'
          setTimeout done, 100

        it 'requires an publicKey', (done)->
          @client.on 'data', (data)->
            return unless data.action == 'error'
            console.log("GOT DATA", data)
            expect(data.error).to.equal("INVALID_PUBLIC_KEY")
            expect(data.message).to.equal("invalid publicKey: not-valid-key provided")
            done()

          @client.write action: 'call', otherIdentity: 'meee', publicKey: 'not-valid-key'

        it 'sends the other client a room', (done)->
          @client.on 'data', (data)->
            return unless data.action == 'incomingcall'
            expect(data.room).to.have.length(64)
            expect(data.sparkId).to.have.length(36)
            done()
          ensurePeerConnecitonMade 1, (err)=>
            return done(err) if err
            @otherClient.write action: 'call', otheridentity: 'meee', publicKey: 'this-is-a-real-api-key'
