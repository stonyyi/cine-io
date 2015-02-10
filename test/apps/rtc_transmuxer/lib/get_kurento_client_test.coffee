getKurentoClient = Cine.app('rtc_transmuxer/lib/get_kurento_client')
kurento = require("kurento-client")

describe 'getKurentoClient', ->

  afterEach ->
    getKurentoClient._clear()

  it 'tries to connect via websockets to a kurento client', (done)->
    getKurentoClient (err, client)->
      expect(err).to.contain("Could not find media server at address ws://kurento-media-server/kurento.")
      done()

  describe 'stubbed connection', ->

    beforeEach ->
      @connectStub = sinon.stub getKurentoClient, '_getClient'
      @connectStub.onFirstCall().callsArgWith 0, null, "connected"
      @connectStub.onSecondCall().callsArgWith 0, null, "connected2"

    afterEach ->
      @connectStub.restore()

    it 'connects', (done)->
      getKurentoClient (err, client)->
        expect(err).to.be.null
        expect(client).to.equal("connected")
        done()

    it 'returns the same object', (done)->
      getKurentoClient (err, client)->
        expect(err).to.be.null
        getKurentoClient (err, client)->
          expect(client).to.equal("connected")
          done()
