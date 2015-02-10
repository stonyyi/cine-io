cp = require('child_process')
StreamToRtmpReplicator = Cine.app('input_to_rtmp_streamer/lib/stream_to_rtmp_replicator')
FakeSpawn = Cine.require('test/helpers/fake_child_process_spawn')

describe 'StreamToRtmpReplicator', ->
  beforeEach ->
    @subject = new StreamToRtmpReplicator

  beforeEach ->
    @spawnStub = sinon.stub cp, 'spawn'
    @spawnStub.returns new FakeSpawn

  afterEach ->
    @spawnStub.restore()

  describe '#startStreamer', ->
    it 'creates a streamer when one does not exist', ->
      streamer = @subject.startStreamer('fake name', 'fake key', 'some input')
      expect(@subject.streamers['fake name']).to.equal(streamer)

    it 'does not duplicate streamers', ->
      streamer = @subject.startStreamer('fake name', 'fake key', 'some input')
      streamer2 = @subject.startStreamer('fake name', 'fake key2', 'some input 3')
      expect(@subject.streamers['fake name']).to.equal(streamer)

  describe 'stopStreamer', ->
    it 'calls stop on the streamer', ->
      streamer = @subject.startStreamer('fake name', 'fake key', 'some input')
      sinon.stub streamer, 'stop'
      @subject.stopStreamer('fake name')
      expect(streamer.stop.calledOnce).to.be.true
    it 'does not fail when a streamer does not exist', ->
      expect(@subject.stopStreamer()).to.equal('did nothing')
