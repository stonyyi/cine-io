FfmpegStreamer = Cine.app('input_to_rtmp_streamer/lib/ffmpeg_streamer')
cp = require('child_process')
FakeSpawn = Cine.require('test/helpers/fake_child_process_spawn')

describe 'FfmpegStreamer', ->

  beforeEach ->
    @spawnStub = sinon.stub cp, 'spawn'
    @spawnStub.returns new FakeSpawn

  afterEach ->
    expect(@spawnStub.called).to.be.true
    @spawnStub.restore()

  beforeEach ->
    @input = 'the input'
    @output = 'the output'

  it 'calls to ffmpeg', (done)->
    expectedFFmpegOptions = [
      "-re"
      "-nostats"
      "-i", "the input"
      "-c:v", "libx264", "-preset", "ultrafast", "-crf", "23", "-maxrate", "2500k"
      "-c:a", "libfdk_aac"
      "-c:d", "copy"
      "-map", "0"
      "-f", "flv"
      "the output"
    ]
    endCallback = =>
      args = @spawnStub.firstCall.args
      expect(args[0]).to.equal('ffmpeg')
      expect(args[1]).to.deep.equal(expectedFFmpegOptions)
      done()
    streamer = new FfmpegStreamer(@input, @output, endCallback)
    streamer.stop()

  it 'properly kills ffmpeg', (done)->
    endCallback = ->
      expect(streamer.ffmpegSpawn.kill.firstCall.args[0]).to.equal('SIGTERM')
      done()
    streamer = new FfmpegStreamer(@input, @output, endCallback)
    streamer.stop()

  it 'does not retry ffmpeg if it exits properly', (done)->
    endCallback = =>
      expect(@spawnStub.calledOnce).to.be.true
      done()
    streamer = new FfmpegStreamer(@input, @output, endCallback)
    originalFFmpeg = streamer.ffmpegSpawn
    originalFFmpeg.trigger('close', 0)

  it 'retries ffmpeg 1 time if it exits poorly', (done)->
    endCallback = =>
      expect(@spawnStub.calledTwice).to.be.true
      done()
    streamer = new FfmpegStreamer(@input, @output, endCallback)
    originalFFmpeg = streamer.ffmpegSpawn
    originalFFmpeg.trigger('close', 1)
    streamer.stop()

  it 'only retries ffmpeg 1 time if it exits poorly', (done)->
    endCallback = =>
      expect(@spawnStub.calledTwice).to.be.true
      done()
    streamer = new FfmpegStreamer(@input, @output, endCallback)
    originalFFmpeg = streamer.ffmpegSpawn
    originalFFmpeg.trigger('close', 1)
    originalFFmpeg.trigger('close', 1)
