RTMP_REPLICATOR_HOST = process.env.RTMP_REPLICATOR_HOST || 'rtmp-replicator'
FfmpegStreamer = Cine.app('input_to_rtmp_streamer/lib/ffmpeg_streamer')
debug = require('debug')("cine:input_to_rtmp_streamer:stream_to_rtmp_replicator")

module.exports = class StreamToRtmpReplicator
  constructor: ->
    @streamers = {}

  startStreamer: (streamName, streamKey, input)->
    @streamers[streamName] ||= @_createNewStreamer(streamName, streamKey, input)

  _createNewStreamer: (streamName, streamKey, input)->
    output = "rtmp://#{RTMP_REPLICATOR_HOST}:1935/live/#{streamName}?#{streamKey}"

    endFunction = =>
      delete @streamers[streamName]

    new FfmpegStreamer(input, output, endFunction)

  stopStreamer: (streamName)->
    streamer = @streamers[streamName]
    return 'did nothing' unless streamer
    debug("stopping streamer")
    streamer.stop()
