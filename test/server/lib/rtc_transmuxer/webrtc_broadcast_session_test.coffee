async = require('async')
WebRTCBroadcastSession = Cine.server_lib("rtc_transmuxer/webrtc_broadcast_session")
getKurentoClient = Cine.server_lib('rtc_transmuxer/get_kurento_client')
EdgecastStream = Cine.server_model('edgecast_stream')
BroadcastPipeline = Cine.server_lib("rtc_transmuxer/broadcast_pipeline")
FakeKurento = Cine.require('test/helpers/fake_kurento')

describe 'WebRTCBroadcastSession', ->

  beforeEach (done)->
    @stream = new EdgecastStream(streamName: 'my name', streamKey: 'real key')
    @stream.save done

  beforeEach ->
    @subject = new WebRTCBroadcastSession @stream._id.toString(), 'real key'

  it 'takes a streamId and a streamKey', ->
    expect(@subject.streamId).to.equal(@stream._id.toString())
    expect(@subject.streamKey).to.equal('real key')

  describe '#handleOffer', ->
    it 'requires a real stream', (done)->
      session = new WebRTCBroadcastSession((new EdgecastStream)._id.toString(), 'fake2')
      session.handleOffer 'some offer', (err, answer)->
        expect(err).to.equal("not found")
        done()

    it 'requires the correct password', (done)->
      session = new WebRTCBroadcastSession(@stream._id.toString(), 'fake key')
      session.handleOffer 'some offer', (err, answer)->
        expect(err).to.equal("incorrect password")
        done()

    describe 'success', ->

      beforeEach ->
        @connectStub = sinon.stub getKurentoClient, '_getClient'
        @connectStub.callsArgWith 0, null, new FakeKurento.FakeKurento

      afterEach ->
        @connectStub.restore()

      beforeEach ->
        postBody =
          streamName: 'my name'
          streamKey: 'real key'
          input: 'http://some-kurento-url/some-id'
        @inputToRtmpStreamerNock = requireFixture('nock/start_input_to_rtmp_streamer')(postBody)

      afterEach (done)->
        errorLogged = false
        testFunction = -> errorLogged
        checkFunction = (callback)=>
          errorLogged = @inputToRtmpStreamerNock.isDone()
          setTimeout callback
        async.until testFunction, checkFunction, done

      beforeEach ->
        @processOfferSpy = sinon.spy BroadcastPipeline::, 'processOffer'
        @startSpy = sinon.spy BroadcastPipeline::, 'start'

      afterEach ->
        @processOfferSpy.restore()
        @startSpy.restore()

      beforeEach (done)->
        @subject.handleOffer 'some offer', done

      it 'creates a broadcast pipeline', ->
        expect(@subject.broadcastPipeline instanceof BroadcastPipeline).to.be.true

      it 'has the broadcast pipeline handle the offer', ->
        expect(@processOfferSpy.calledOnce).to.be.true
        expect(@processOfferSpy.firstCall.args[0]).to.equal('some offer')

      it 'starts the broadcast pipeline broadcast', ->
        expect(@startSpy.calledOnce).to.be.true

  describe 'stop', ->
    it 'does nothing when there is no pipeline', ->
      @subject.stop()

    describe 'with a pipeline', ->
      beforeEach ->
        postBody =
          streamName: 'my name'
          streamKey: 'real key'
        @inputToRtmpStreamerNock = requireFixture('nock/stop_input_to_rtmp_streamer')(postBody)

      afterEach (done)->
        errorLogged = false
        testFunction = -> errorLogged
        checkFunction = (callback)=>
          errorLogged = @inputToRtmpStreamerNock.isDone()
          setTimeout callback
        async.until testFunction, checkFunction, done

      beforeEach ->
        @stopSpy = sinon.spy BroadcastPipeline::, 'stop'

      afterEach ->
        @stopSpy.restore()

      beforeEach (done)->
        @subject.handleOffer 'some offer', done

      it 'calls stop to the broadcast pipeline', ->
        @subject.stop()
        expect(@stopSpy.calledOnce).to.be.true
