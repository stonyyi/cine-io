_ = require('underscore')
async = require('async')
Primus = Cine.require('apps/rtc_transmuxer/node_modules/primus')
Socket = Primus.createSocket({transformer: 'sockjs', parser: 'json'})
portfinder = Cine.require('apps/rtc_transmuxer/node_modules/portfinder')
Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
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
      newEnv.RUN_AS = "rtc_transmuxer"
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

  beforeEach (done)->
    @project = new Project(publicKey: 'this-is-a-real-api-key', secretKey: 'super-secret-key')
    @project.save done

  beforeEach (done)->
    @stream = new EdgecastStream(streamName: 'my stream name', streamKey: 'my stream key', _project: @project._id)
    @stream.save done

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
        return if data.action == 'rtc-servers'
        expect(data).to.deep.equal(action: 'ack', source: 'auth')
        done()
      @client.write action: 'auth', publicKey: 'this-is-a-real-api-key', uuid: '111'

  describe 'broadcast-start', ->

    beforeEach ->
      @client.write action: 'auth', publicKey: 'this-is-a-real-api-key', uuid: '111'

    it 'gets an ack', (done)->
      @client.on 'data', (data)->
        return unless data.action == 'ack' && data.source == 'broadcast-start'
        done()

      @client.write action: 'broadcast-start'

    it 'requires a valid offer', (done)->
      @client.on 'data', (data)->
        return unless data.action == 'error' && data.error == 'invalid offer'
        done()

      @client.write action: 'broadcast-start'

    it 'requires a streamId and streamKey', (done)->
      @client.on 'data', (data)->
        return unless data.action == 'error' && data.error == 'stream key and stream id required'
        done()

      @client.write action: 'broadcast-start', offer: {sdp: 'some offer'}

    it "returns an answer (well now it's an error)", (done)->
      @client.on 'data', (data)->
        return unless data.action == 'error'
        expect(data.error).to.contain('Could not find media server at')
        done()

      params =
        action: 'broadcast-start'
        offer: {sdp: 'valid offer'}
        streamId: @stream._id.toString()
        streamKey: 'my stream key'
      @client.write params

  describe 'broadcast-stop', ->
    it 'gets an ack', (done)->
      @client.on 'data', (data)->
        return unless data.action == 'ack' && data.source == 'broadcast-stop'
        done()

      @client.write action: 'broadcast-stop'
