getKurentoClient = Cine.app('rtc_transmuxer/lib/get_kurento_client')

describe 'getKurentoClient', ->

  afterEach ->
    getKurentoClient._clear()

  describe 'failure', ->
    beforeEach ->
      @connectStub = sinon.stub getKurentoClient, '_getClient'
      @connectStub.callsArgWith 0, "fail"

    afterEach ->
      @connectStub.restore()

    it 'tries to connect via websockets to a kurento client', (done)->
      getKurentoClient (err, client)->
        expect(err).to.contain("Could not find media server at address ws://kurento-media-server:8888/kurento.")
        done()

  describe 'success', ->

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
