Base = require('./base')
fs = require('fs')
_ = require('underscore')
async = require('async')
request = require('request')
cp = require('child_process')
runMe = !module.parent

express = require('express')

ffmpeg = "/usr/local/bin/ffmpeg"
app = exports.app = Base.app()

thomasBoxTempAccessToken = "bOi7DYgogoizTF9mMVeU7rQSNJ4XRCox"

createBoxStream = (fileId, accessToken)->
  requestOptions =
    url: "https://www.box.com/api/2.0/files/#{fileId}/content"
    method: 'GET'
    headers:
      Authorization: "Bearer #{accessToken}"
  request(requestOptions)

createFFmpegStreamer = ->
  ffmpegOptions = [
    '-i', 'pipe:0',
    '-c:v', 'libvpx',
    # '-strict', '-2'
    '-b:v', '1M'
    # '-preset', 'ultrafast',
    # '-crf', '23'
    '-threads', 'auto'
    '-deadline', 'realtime'
    '-c:a', 'libvorbis',
    # '-bsf:v', 'h264_mp4toannexb'
    # '-c:d', 'copy',
    '-f', 'webm',
    # '-movflags', 'faststart'
    'pipe:1'
  ]

  # ffmpegOptions.push('pipe:1')

  ffmpegSpawn = cp.spawn(ffmpeg, ffmpegOptions)


  # ffmpegSpawn.stderr.setEncoding('utf8')
  # ffmpegSpawn.stderr.on 'data', (data)->
  #   if (/^execvp\(\)/.test(data))
  #     console.log('Failed to start child process.')
  #   console.log("ffmpeg stderr", data)

  ffmpegSpawn.on 'close', (code)->
    if code != 0
      console.log('ffmpeg process exited with code ' + code)
    console.log("ffmpeg done")

  ffmpegSpawn


videoType = (format)->
  {
    'flv': 'video/x-flv'
    'mp4': 'video/mp4'
    'vp8': 'video/webm'
  }

sendAndStreamFile = (file, req, res)->
  options =
    file: file
    format: 'vp8'
    # extra: "-movflags faststart"

  res.setHeader("content-type", videoType(options.format))

  boxFileStream = createBoxStream("22040211383", thomasBoxTempAccessToken)
  # todo check for file not there
  ffmpegSpawn = createFFmpegStreamer()

  boxFileStream.pipe(ffmpegSpawn.stdin)

  ffmpegSpawn.stdout.pipe(res)

# FROM BOX
app.get '/', (req, res)->
  res.send """
    <html>
    <body>
    <h1> Hello </h1>
    <video controls autoplay>
      <source src="/movie.webm" type="video/webm">
    </video>
    </body>
    </html>
  """

app.get '/movie.webm', (req, res)->
  sendAndStreamFile("pipe:0", req, res)
# END FROM BOX

# DOWNLOAD AND STREAM
# app.use express.static "/Users/thomas/work/tmp"
# app.get '/', (req,res)->
#   requestOptions =
#     url: 'http://localhost:8182/stage5.flv'
#     method: "GET"
#   file = Cine.path('ignored/downloaded.flv')
#   request(requestOptions).pipe(fs.createWriteStream(file))
#   sendAndStreamFile(file, req, res)
# END DOWNLOAD AND STREAM

# SAVER
# app.use express.static "/Users/thomas/work/tmp"
# app.get '/', (req,res)->
#   requestOptions =
#     url: 'http://localhost:8182/stage5.flv'
#     method: "GET"
#   outputFile = Cine.path('ignored/downloaded.flv')
#   request(requestOptions).pipe(fs.createWriteStream(outputFile))
#   res.send(200)
# END SAVER

# STREAMER
# app.get '/', (req,res)->
#   file = "/Users/thomas/work/tmp/stage5.flv"
#   sendAndStreamFile(file, req, res)
# END STREAMER

# json options
#  file: full path to file
#  format: output format
#  videoCodec: output video codec
#  audioCodec: output audio codec
#  data: true/false to keep the data channel
#  extra: extra stuff to send to ffmpeg
app.post '/', (req, res)->
  file = req.body?.file
  sendAndStreamFile(file, req, res)

Base.listen app, 8182 if runMe
