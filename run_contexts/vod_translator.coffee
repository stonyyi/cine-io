Base = require('./base')
fs = require('fs')
_ = require('underscore')
cp = require('child_process')
runMe = !module.parent

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
  constructor: (file)->
    options =
      file: file
      format: 'mp4'
      videoCodec: 'copy'
      audioCodec: 'copy'
      dataCodec: 'copy'
      extra: "-movflags faststart"

    @handler = new FFmpegHandler(options)

  # returns(err, outputFile)
  process: (@callback)=>
    @handler.process(callback)

class FFmpegHandler
  constructor: (@options)->
    _.defaults(@options, deleteOriginal: true)
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


# json options
#  file: full path to file
#  format: output format
#  videoCodec: output video codec
#  audioCodec: output audio codec
#  data: true/false to keep the data channel
#  extra: extra stuff to send to ffmpeg

exports.jobProcessor = (job, done)->
  console.log("running job", job.data)
  file = job.data.file
  return done("no file passed in") unless file
  fs.exists file, (exists)->
    return done("Could not find file #{file}") unless exists

    handler = new VodTranslator(file)
    handler.process (err, outputFile)->
      if err
        console.log("Could not process file", file, err)
        done(err)
      else
        console.log("processed file", file)
        Base.scheduleJob Base.getQueueName('vod_bookkeeper'), file: outputFile, done

Base.processJobs 'vod_translator', exports.jobProcessor if runMe
