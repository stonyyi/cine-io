_ = require('underscore')
Base = require('../base')
runMe = !module.parent
fs = require('fs')

fileName = "/Users/thomas/work/cine-io/cine/apps/chunked_rtmp_streamer/wtf.webm"
# writer = fs.createWriteStream(fileName)

cp = require('child_process')
Debug = require('debug')

RTMP_REPLICATOR_HOST = process.env.RTMP_REPLICATOR_HOST || 'rtmp-replicator'
ffmpeg = "ffmpeg"
MAX_FFMPEG_RETRIES = 1

Debug.enable('chunked_rtmp_streamer:*')
debug = Debug("chunked_rtmp_streamer:index")

app = exports.app = Base.app("chunked rtmp streamer", log: false)

class FfmpegStreamer
  constructor: (@output)->
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
      #'-nostats', # do not constantly output frame number/time
      '-i', 'pipe:0', # take stdin as the input
      '-loglevel', 'debug' #log level
      # '-c:v', 'copy', # h.264
      # begin same as rtmp-stylist
      '-c:v', 'libx264',
      '-preset', 'ultrafast',
      '-crf', '23',
      '-maxrate', '2500k',
      #'-x264opts', 'keyint=30',
      # end same as rtmp-stylist

      #for audio, it outputs in mp3, we can either:
      # change it to aac:
      '-c:a', 'libfdk_aac',
      # '-bsf:a', 'aac_adtstoasc', #this didn't help
      # or downsample to 44100:
      # '-ar', '44100',
      # end audio
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
      @endFFmpegCallback() if typeof @endFFmpegCallback == 'function'

  reversePipe: (contentStream)->
    contentStream.on 'data', (data)=>
      return debug("not writing body") if @stopped
      # debug("Writing body yo")
      @ffmpegSpawn.stdin.write(data)
      # writer.write(data)

    contentStream.on 'end', =>
      # ABSORB END
      #debug("end of body yo, but I ain't tellin ffmpeg")

  stop: (@endFFmpegCallback)=>
    debug("INDICATING STOP")
    @stopped = true
    @_stopFFmpeg()

  _stopFFmpeg: ->
    # FFMPEG didn't like killing the child process
    # when ending stdin, ffmpeg will close itself.
    # V8 will gc this child process because we delete all references to it*
    # *I think
    @ffmpegSpawn.stdin.end()
    # writer.end()

class FfmpegStreamers
  constructor: ->
    @streamers = {}

  getStreamer: (streamName, streamKey)->
    @streamers[streamName] ||= @_createNewStreamer(streamName, streamKey)

  _createNewStreamer: (streamName, streamKey)->
    output = "rtmp://#{RTMP_REPLICATOR_HOST}:1935/live/#{streamName}?#{streamKey}"
    new FfmpegStreamer(output)

  stopStreamer: (streamName)->
    streamer = @streamers[streamName]
    return unless streamer
    debug("stopping streamer")
    streamer.stop =>
      delete @streamers[streamName]

streamers = new FfmpegStreamers

app.get '/', (req, res)->
  res.send("I am the chunked_rtmp_streamer")

app.put '/:streamName/:streamKey', (req, res)->
  streamName = req.param('streamName')
  streamKey = req.param('streamKey')
  # debug("got data", streamName, streamKey)
  streamers.getStreamer(streamName, streamKey).reversePipe(req)
  res.sendStatus(200)

app.post '/stop', (req, res)->
  streamName = req.body.streamName
  debug("stopping", streamName)
  streamers.stopStreamer(streamName)
  res.sendStatus(200)

Base.listen app, 8185 if runMe
