_ = require('underscore')
Base = require('../base')
runMe = !module.parent

cp = require('child_process')
Debug = require('debug')

RTMP_REPLICATOR_HOST = process.env.RTMP_REPLICATOR_HOST || 'rtmp-replicator'
ffmpeg = "ffmpeg"
MAX_FFMPEG_RETRIES = 1

Debug.enable('input_to_rtmp_streamer:*')
debug = Debug("input_to_rtmp_streamer:index")

app = exports.app = Base.app("input to rtmp streamer", log: false)

class FfmpegStreamer
  constructor: (@input, @output, @endCallback)->
    debug("creating ffmpeg streamer")
    @start()

  start: ->
    @retries = 0
    @startTime = new Date
    @_startFlow()

  _startFlow: ->
    @_startFfmpeg()

  _startFfmpeg: ->
    delete @startTime

    ffmpegOptions = [
      '-re', # read in "real time", don't read too quickly
      '-nostats', # do not constantly output frame number/time
      '-i', @input, # take kurento HttpEndpoint as the input
      #'-loglevel', 'debug' #log level
      # '-c:v', 'copy', # h.264
      # begin same as rtmp-stylist
      '-c:v', 'libx264',
      '-preset', 'ultrafast',
      '-crf', '23',
      '-maxrate', '2500k',
      #'-x264opts', 'keyint=30',
      # end same as rtmp-stylist

      '-c:a', 'libfdk_aac',
      '-c:d', 'copy', # don't think this does anything
      '-map', '0',
      '-f', 'flv',
      @output
    ]
    debug('running ffmpeg', ffmpegOptions)
    @ffmpegSpawn = cp.spawn(ffmpeg, ffmpegOptions)

    @ffmpegSpawn.stderr.setEncoding('utf8')
    @ffmpegSpawn.stdin.on 'finish', ->
      debug('not allowed to write to ffmpeg anymore');

    @ffmpegSpawn.stderr.on 'data', (data)=>
      @startTime ||= new Date
      if (/^execvp\(\)/.test(data))
        debug('Failed to start child process.')
      debug("ffmpeg stderr", data)

    @ffmpegSpawn.on 'error', (error)->
      debug("I JUST ERRORED YO", error)

    @ffmpegSpawn.on 'close', (code)=>
      if code != 0
        debug('ffmpeg process exited with code ', code)
        # 6 seconds from starting ffmpeg to seeing if it dies
        # kinda arbitrary
        sixSecondsAgo = new Date
        sixSecondsAgo.setSeconds(sixSecondsAgo.getSeconds() - 6)
        # sometimes there's bad input
        debug(code, code == 1, @startTime, sixSecondsAgo)
        badExit = code == 1
        lessThanSixSecondsAgo = @startTime >= sixSecondsAgo
        retryable = @retries < MAX_FFMPEG_RETRIES
        if !@stopped && badExit && lessThanSixSecondsAgo && retryable
          @retries += 1
          debug("RESTARTING FFMPEG RETRY:", @retries)
          @_startFlow()
      debug("ffmpeg done")
      @endCallback()

  stop: ->
    debug("INDICATING STOP")
    @stopped = true
    @_stopFFmpeg()

  _stopFFmpeg: ->
    @ffmpegSpawn.kill("SIGTERM")

class FfmpegStreamers
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
    return unless streamer
    debug("stopping streamer")
    streamer.stop()

streamers = new FfmpegStreamers

app.get '/', (req, res)->
  res.send("I am the input_to_rtmp_streamer")

app.post '/start', (req, res)->
  streamName = req.body.streamName
  streamKey = req.body.streamKey
  input = req.body.input
  debug("starting", streamName, streamKey, input)

  streamers.startStreamer(streamName, streamKey, input)

  res.sendStatus(200)

app.post '/stop', (req, res)->
  streamName = req.body.streamName
  debug("stopping", streamName)
  streamers.stopStreamer(streamName)
  res.sendStatus(200)

Base.listen app, 8185 if runMe
