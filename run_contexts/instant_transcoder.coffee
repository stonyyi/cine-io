Base = require('./base')
fs = require('fs')
_ = require('underscore')
async = require('async')
request = require('request')
cp = require('child_process')
runMe = !module.parent
tailingStream = require('tailing-stream')
express = require('express')

ffmpeg = "ffmpeg"
app = exports.app = Base.app()

callFfmpeg = (command, callback)->
  now = new Date
  cmd = "#{ffmpeg} #{command}"
  console.log("Executing FFMPEG at #{now}:", cmd)
  cp.exec cmd, (error, stdout, stderr)->
    console.log("Done FFmpeg", (new Date - now) / 1000 + " seconds")
    if (error)
      console.log('exec error: ' + error)
      return callback(error)
    console.log('ffmpeg stdout: ' + stdout)
    console.log('ffmpeg stderr: ' + stderr)
    callback()

class FFmpegHandler
  constructor: (@options)->
    _.defaults(@options, deleteOriginal: false)
    @outputFile = @_createOutputFile()

  # returns(err, outputFile)
  process: (@callback)=>
    ffmpegCommand = "-i #{@options.file}"
    ffmpegCommand += " -c:v #{@options.videoCodec}" if _.has @options, 'videoCodec'
    ffmpegCommand += " -c:a #{@options.audioCodec}" if _.has @options, 'audioCodec'
    ffmpegCommand += " -c:d #{@options.dataCodec}" if _.has @options, 'dataCodec'
    ffmpegCommand += " #{@options.extra}" if @options.extra
    ffmpegCommand += " -f #{@options.format} #{@outputFile}"
    console.log ffmpegCommand
    callFfmpeg ffmpegCommand, @_processed

  _processed: (err)=>
    return @callback(err, @outputFile) if err
    return @_deleteOriginal() if @options.deleteOriginal
    @callback(null, @outputFile)

  _deleteOriginal: =>
    fs.unlink @options.file, (err)=>
      @callback(err, @outputFile)

  # /full/path/to/file.flv, format: mp4
  # /full/path/to/file.mp4
  # todo what happens when the output file is the same as the input file
  # /full/path/to/file.mp4, format: mp4
  _createOutputFile: ->
    parts = @options.file.split('.')
    _.initial(parts).concat(@options.format).join('.')


videoType = (format)->
  {
    'flv': 'video/x-flv'
    'mp4': 'video/mp4'
  }

waitForFileToExist = (file, done)->
  fileExists = false
  testFunction = -> fileExists
  checkFunction = (callback)->
    fs.exists file, (exists)->
      fileExists = exists
      setTimeout callback, 100
  async.until testFunction, checkFunction, done

sendAndStreamFile = (file, req, res)->
  return res.status(400).send("usage: [POST] /, {file: '/full/path/to/file'}") unless file
  fs.exists file, (exists)->
    return res.status(400).send("Could not find file #{file}") unless exists

    options =
      file: file
      format: 'mp4'
      videoCodec: 'copy'
      audioCodec: 'copy'
      dataCodec: 'copy'
      extra: "-movflags faststart"
    handler = new FFmpegHandler(options)

    res.setHeader('Content-disposition', "attachment; filename=myfile.#{options.format}")
    res.setHeader("content-type", videoType(options.format))

    waitForFileToExist handler.outputFile, (err)->
      console.log("startingToStream", handler.outputFile)
      tailingStream.createReadStream(handler.outputFile).pipe(res)

    handler.process (err)->
      if err
        console.log("Could not process file", file, err)
      else
        console.log("Processed file", file)


app.use express.static "/Users/thomas/work/tmp"



# saver
app.get '/', (req,res)->
  requestOptions =
    url: 'http://localhost:8182/stage5.flv'
    method: "GET"
  outputFile = Cine.path('ignored/downloaded.flv')
  request(requestOptions).pipe(fs.createWriteStream(outputFile))
  request requestOptions
  res.send(200)

# streamer
# app.get '/', (req,res)->
#   file = "/Users/thomas/work/tmp/stage5.flv"
#   sendAndStreamFile(file, req, res)

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
