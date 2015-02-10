BroadcastPipeline = Cine.app("rtc_transmuxer/lib/broadcast_pipeline")
FakeKurento = Cine.require('test/helpers/fake_kurento')

describe 'BroadcastPipeline', ->

  beforeEach ->
    @kurento = new FakeKurento.FakeKurento

  beforeEach ->
    @subject = new BroadcastPipeline(@kurento, "the name", "the keyz")

  it 'take a kurentoClient, streamName, and streamKey', ->
    expect(@subject.kurentoClient).to.equal(@kurento)
    expect(@subject.streamName).to.equal("the name")
    expect(@subject.streamKey).to.equal("the keyz")

  describe '#create', ->
    it 'creates a pipeline', (done)->
      @subject.create (err)=>
        expect(err).to.be.undefined
        expect(@kurento.create.calledOnce).to.be.true
        done()

    it 'creates a creates an HttpGetEndpoint', (done)->
      @subject.create (err)=>
        expect(err).to.be.undefined
        expect(@subject.httpGetEndpoint instanceof FakeKurento.FakeHttpGetEndpoint).to.be.true
        expect(@subject.httpGetEndpoint.options).to.deep.equal(terminateOnEOS: true, mediaProfile: 'WEBM')
        done()

    it 'creates a creates a WebRtcEndpoint', (done)->
      @subject.create (err)=>
        expect(err).to.be.undefined
        expect(@subject.webRtcEndpoint instanceof FakeKurento.FakeWebRtcEndpoint).to.be.true
        expect(@subject.webRtcEndpoint.connect.calledOnce).to.be.true
        expect(@subject.webRtcEndpoint.connect.firstCall.args[0]).to.equal(@subject.httpGetEndpoint)
        done()

  describe '#processOffer', ->
    it 'requires create be called', (done)->
      @subject.processOffer "offer", (err, sdpAnswer)->
        expect(err).to.equal("Not initialized")
        done()

    describe 'initialized', ->
      beforeEach (done)->
        @subject.create done

      it 'processes the offer', (done)->
        @subject.processOffer "some offer", (err, answer)=>
          expect(err).to.be.null
          expect(answer).to.equal("some answer")
          expect(@subject.webRtcEndpoint.processOffer.calledOnce).to.be.true
          expect(@subject.webRtcEndpoint.processOffer.firstCall.args[0]).to.equal('some offer')
          done()
  describe '#start', ->

    it 'requires processOffer to be called', (done)->
      @subject.start (err)->
        expect(err).to.equal("not offered")
        done()

    describe 'offered', ->
      beforeEach ->
        postBody =
          streamName: 'the name'
          streamKey: 'the keyz'
          input: 'http://some-kurento-url/some-id'
        @inputToRtmpStreamerNock = requireFixture('nock/start_input_to_rtmp_streamer')(postBody)
      beforeEach (done)->
        @subject.create done
      beforeEach (done)->
        @subject.processOffer "some offer", done

      it 'gets the url from the httpGetEndpoint', (done)->
        @subject.start (err)=>
          expect(err).to.be.unedfined
          expect(@subject.httpGetEndpoint.getUrl.calledOnce).to.be.true
          done()

      it 'tells the input-to-rtmp-streamer to start streaming', (done)->
        @subject.start (err)=>
          expect(err).to.be.unedfined
          expect(@inputToRtmpStreamerNock.isDone()).to.be.true
          done()

  describe '#stop', ->
    beforeEach ->
      postBody =
        streamName: 'the name'
        streamKey: 'the keyz'
      @inputToRtmpStreamerNock = requireFixture('nock/stop_input_to_rtmp_streamer')(postBody)

    it 'tells the rtmp streamer to stop', (done)->
      @subject.stop (err)=>
        expect(err).to.be.unedfined
        expect(@inputToRtmpStreamerNock.isDone()).to.be.true
        done()
    describe 'with a pipeline', ->
      beforeEach (done)->
        @subject.create done
      it 'releases the pipeline', (done)->
        @subject.stop (err)=>
          expect(err).to.be.unedfined
          expect(@subject.pipeline.release.calledOnce).to.be.true
          done()
