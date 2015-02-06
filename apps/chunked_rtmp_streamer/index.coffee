_ = require('underscore')
Base = require('../base')
runMe = !module.parent
http = require('http')
cp = require('child_process')
Debug = require('debug')
Debug.enable('chunked_rtmp_streamer:*')
debug = Debug("chunked_rtmp_streamer:index")

app = exports.app = Base.app("chunked rtmp streamer")

server = http.createServer(app)

RTMP_REPLICATOR_HOST = process.env.RTMP_REPLICATOR_HOST || 'rtmp-replicator'
ffmpeg = "ffmpeg"
MAX_FFMPEG_RETRIES = 1

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
      '-i', 'pipe:0', # take stdin as the input
      '-c:v', 'copy', # h.264

      #for audio, it outputs in mp3, we can either:
      # change it to aac:
      '-c:a', 'libfdk_aac',
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
      debug('NOT ALLOWED TO WRITE TO FFMPEG ANYMORE I THINK');

    @ffmpegSpawn.stderr.on 'data', (data)=>
      @startTime ||= new Date
      if (/^execvp\(\)/.test(data))
        debug('Failed to start child process.')
      debug("ffmpeg stderr", data)

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

  reversePipe: (contentStream)->
    contentStream.on 'data', (data)=>
      debug("Writing body yo")
      @ffmpegSpawn.stdin.write(data)

    contentStream.on 'end', ->
      debug("end of body yo, but I ain't tellin ffmpeg")

  stop: ->
    @stopped = true
    @ffmpegSpawn.kill('SIGHUP') if @ffmpegSpawn

class FfmpegStreamers
  constructor: ->
    @streamers = {}

  getStreamer: (streamName, streamKey)->
    @streamers[streamName] ||= @_createNewStreamer(streamName, streamKey)

  _createNewStreamer: (streamName, streamKey)->
    output = "rtmp://#{RTMP_REPLICATOR_HOST}:1935/live/#{streamName}?#{streamKey}"
    new FfmpegStreamer(output)

streamers = new FfmpegStreamers
app.get '/', (req, res)->
  res.send("I am the chunked_rtmp_streamer")

app.put '/send/:streamName/:streamKey', (req, res)->
  streamName = req.param('streamName')
  streamKey = req.param('streamKey')
  debug("HERE I AMMMM", streamName, streamKey)
  streamers.getStreamer(streamName, streamKey).reversePipe(req)
  res.send('OK')

Base.listen server, 8185 if runMe
