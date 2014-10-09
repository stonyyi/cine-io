Base = require('./base')
fs = require('fs')
_ = require('underscore')
cp = require('child_process')
runMe = !module.parent
app = exports.app = Base.app()

ffmpeg = "ffmpeg"

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

class VodTranslator
  constructor: (@options)->
    _.defaults(@options, deleteOriginal: true)
    @outputFile = @_createOutputFile()

  # returns(err, outputFile)
  process: (@callback)=>
    ffmpegCommand = "-i #{@options.file}"
    ffmpegCommand += " -c:v #{@options.videoCodec}" if _.has @options, 'videoCodec'
    ffmpegCommand += " -c:a #{@options.audioCodec}" if _.has @options, 'audioCodec'
    ffmpegCommand += " -c:d copy" if @options.data
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
  _createOutputFile: ->
    parts = @options.file.split('.')
    _.initial(parts).concat(@options.format).join('.')

# json options
#  file: full path to file
#  format: output format
#  videoCodec: output video codec
#  audioCodec: output audio codec
#  data: true/false to keep the data channel

app.post '/', (req, res)->
  file = req.body?.file
  return res.status(400).send("usage: [POST] /, {file: '/full/path/to/file'}") unless file
  fs.exists file, (exists)->
    return res.status(400).send("Could not find file #{file}") unless exists

    handler = new VodTranslator(req.body)
    handler.process (err)->
      if err
        console.log("Could not process file", file, err)
      else
        console.log("Processed file successfully", file)

    res.send("OK")

Base.listen app, 8183 if runMe
