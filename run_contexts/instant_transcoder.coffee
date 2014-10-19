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

createBoxStream = (fileId, accessToken)->
  requestOptions =
    url: "https://www.box.com/api/2.0/files/#{fileId}/content"
    method: 'GET'
    headers:
      Authorization: "Bearer #{accessToken}"
  request(requestOptions)

createFFmpegStreamer = (format)->
  switch format
    when 'vp8'
      ffmpegOptions = [
        '-i', 'pipe:0',
        '-c:v', 'libvpx',
        # '-strict', '-2'
        '-b:v', '1M',
        # '-preset', 'ultrafast',
        # '-crf', '23'
        '-threads', 'auto',
        '-deadline', 'realtime',
        '-c:a', 'libvorbis',
        # '-bsf:v', 'h264_mp4toannexb'
        # '-c:d', 'copy',
        '-f', 'webm',
        # '-movflags', 'faststart'
        'pipe:1'
      ]
    when 'mp4'
      # not really working
      # http://stackoverflow.com/questions/8616855/how-to-output-fragmented-mp4-with-ffmpeg
      ffmpegOptions = [
        '-re',
        '-i', 'pipe:0',
        # '-g', '52'
        '-c:v', 'libx264',
        '-preset', 'ultrafast',
        '-crf', '23'
        '-threads', 'auto'
        '-deadline', 'realtime'
        '-c:a', 'libfaac',
        '-c:d', 'copy',
        # '-movflags', 'frag_keyframe+',
        '-f', 'mp4',
        'pipe:1'
      ]
    when 'mpegts'
      # not working
      # http://www.ioncannon.net/programming/452/iphone-http-streaming-with-ffmpeg-and-an-open-source-segmenter/
      ffmpegOptions = [
        '-i', 'pipe:0',
        # '-g', '52'
        '-c:v', 'libx264',
        # '-preset', 'ultrafast',
        # '-crf', '23',
        # '-threads', 'auto',
        # '-deadline', 'realtime',
        '-c:a', 'libfaac',
        # '-c:d', 'copy',
        # '-flags', '+loop',
        '-f', 'mpegts',
        'pipe:1'
      ]
    else
      throw new Error("Unknown format #{format}")
  console.log("running ffmpeg with options", ffmpegOptions)
  # ffmpegOptions.push('pipe:1')

  ffmpegSpawn = cp.spawn(ffmpeg, ffmpegOptions)


  ffmpegSpawn.stderr.setEncoding('utf8')
  ffmpegSpawn.stderr.on 'data', (data)->
    if (/^execvp\(\)/.test(data))
      console.log('Failed to start child process.')
    console.log("ffmpeg stderr", data)

  ffmpegSpawn.on 'close', (code)->
    if code != 0
      console.log('ffmpeg process exited with code ' + code)
    console.log("ffmpeg done")

  ffmpegSpawn


videoType = (format)->
  {
    'flv': 'video/x-flv'
    'mp4': 'video/mp4'
    'mpegts': 'video/mp2t'
    'vp8': 'video/webm'
  }

sendAndStreamFile = (accessToken, fileId, res, format)->
  console.log("streaming", accessToken, fileId, format)

  res.setHeader("content-type", videoType(format))

  boxFileStream = createBoxStream(fileId, accessToken)
  # todo check for file not there
  ffmpegSpawn = createFFmpegStreamer(format)

  boxFileStream.pipe(ffmpegSpawn.stdin)

  ffmpegSpawn.stdout.pipe(res)

# FROM BOX
app.get '/webm', (req, res)->
  accessToken = req.param('accessToken')
  fileId = req.param('fileId')
  sendAndStreamFile(accessToken, fileId, res, 'vp8')

app.get '/mp4', (req, res)->
  accessToken = req.param('accessToken')
  fileId = req.param('fileId')
  sendAndStreamFile(accessToken, fileId, res, 'mp4')
app.get '/mpegts', (req, res)->
  accessToken = req.param('accessToken')
  fileId = req.param('fileId')
  sendAndStreamFile(accessToken, fileId, res, 'mpegts')
# END FROM BOX

Base.listen app, 8182 if runMe
