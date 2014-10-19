Base = require('./base')
fs = require('fs')
_ = require('underscore')
async = require('async')
request = require('request')
cp = require('child_process')
runMe = !module.parent
tailingStream = require('tailing-stream')
express = require('express')

ffmpeg = "/usr/local/bin/ffmpeg"
app = exports.app = Base.app()

thomasBoxTempAccessToken = "NpPw6SYqkBDpigoC2fWTjxbMjui0Fdv5"

# callFfmpeg = (command, callback)->
#   now = new Date
#   ffmpegCmd = "#{ffmpeg} #{command}"
#   console.log("Executing FFMPEG at #{now}:", ffmpegCmd)
#   fullCmd = "#{curl} -L --header \"Authorization: Bearer #{thomasBoxTempAccessToken}\" https://www.box.com/api/2.0/files/22040211383/content | #{ffmpegCmd}"
#   console.log("Executing fullCmd at #{now}:", fullCmd)
#   cp.spawn(fullCmd)#, (error)->
    # console.log("Done FFmpeg", (new Date - now) / 1000 + " seconds")
    # if (error)
    #   console.log('exec error: ' + error)
    #   return callback(error)
    # # console.log('ffmpeg stdout: ' + stdout)
    # # console.log('ffmpeg stderr: ' + stderr)
    # callback()

class FFmpegHandler
  constructor: (@options)->
    _.defaults(@options, deleteOriginal: false)
    @outputFile = @_createOutputFile()

  # returns(err, outputFile)
  stream: ->
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

    ffmpegSpawn = cp.spawn(ffmpeg, ffmpegOptions)

    requestOptions =
      url: 'https://www.box.com/api/2.0/files/22040211383/content'
      method: 'GET'
      headers:
        Authorization: "Bearer #{thomasBoxTempAccessToken}"
    request(requestOptions).pipe(ffmpegSpawn.stdin)

    # ffmpegSpawn.stderr.setEncoding('utf8')
    # ffmpegSpawn.stderr.on 'data', (data)->
    #   if (/^execvp\(\)/.test(data))
    #     console.log('Failed to start child process.');
    #   console.log("ffmpeg stderr", data)

    ffmpegSpawn.on 'close', (code)->
      if code != 0
        console.log('ffmpeg process exited with code ' + code)
      console.log("ffmpeg done")
    ffmpegSpawn

  # /full/path/to/file.flv, format: mp4
  # /full/path/to/file.mp4
  # todo what happens when the output file is the same as the input file
  # /full/path/to/file.mp4, format: mp4
  _createOutputFile: ->
    # parts = @options.file.split('.')
    # _.initial(parts).concat(@options.format).join('.')
    "/Users/thomas/work/cine-io/cine/ignored/downloaded.#{@options.format}"

videoType = (format)->
  {
    'flv': 'video/x-flv'
    'mp4': 'video/mp4'
    'vp8': 'video/webm'
  }

# waitForFileToExist = (file, done)->
#   fileExists = false
#   testFunction = -> fileExists
#   checkFunction = (callback)->
#     fs.exists file, (exists)->
#       fileExists = exists
#       setTimeout callback, 100
#   async.until testFunction, checkFunction, done

sendAndStreamFile = (file, req, res)->
  # return res.status(400).send("usage: [POST] /, {file: '/full/path/to/file'}") unless file
  # fs.exists file, (exists)->
    # return res.status(400).send("Could not find file #{file}") unless exists

  options =
    file: file
    format: 'vp8'
    # extra: "-movflags faststart"
  handler = new FFmpegHandler(options)

  # res.setHeader('Content-disposition', "attachment; filename=myfile.#{options.format}")
  res.setHeader("content-type", videoType(options.format))


  # waitForFileToExist handler.outputFile, (err)->
  #   console.log("startingToStream", handler.outputFile)
  #   tailingStream.createReadStream(handler.outputFile).pipe(res)

  ffmpegSpawn = handler.stream()

  ffmpegSpawn.stdout.pipe(res)

  ffmpegSpawn.stderr.setEncoding('utf8')
  ffmpegSpawn.stderr.on 'data', (data)->
    if(/^execvp\(\)/.test(data))
      console.log('failed to start ' + argv.ffmpeg);
      process.exit(1);

# FROM BOX
# app.get '/box-file.flv', (req, res)->
#   console.log("HERE I AM FETCHING")
#   requestOptions =
#     url: 'https://www.box.com/api/2.0/files/22040211383/content'
#     method: 'GET'
#     headers:
#       Authorization: "Bearer #{thomasBoxTempAccessToken}"
#   request(requestOptions).pipe(res)

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
