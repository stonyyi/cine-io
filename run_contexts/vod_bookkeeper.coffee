Base = require('./base')
fs = require('fs')
_ = require('underscore')
async = require('async')
runMe = !module.parent

streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')
EdgecastFtpInfo = Cine.config('edgecast_ftp_info')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
EdgecastRecordings = Cine.server_model('edgecast_recordings')
makeFtpDirectory = Cine.server_lib("stream_recordings/make_ftp_directory")
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')

finalDirectory = "/vod_bookkeeper_sandbox"

class SaveStreamRecording
  constructor: (@fullFilePath, @stream)->
    @fileName = _.last(@fullFilePath.split('/'))


  process: (@callback)=>
    return callback('stream not assigned to project') unless @stream._project
    @ftpClient = edgecastFtpClientFactory @callback, @_waterfall

  _waterfall: =>
    waterfallCalls = [@_findStreamProject, @_mkProjectDir, @_uploadToProjectDir, @_addRecordingToEdgecastRecordings, @_deleteOriginal]
    async.waterfall waterfallCalls, @callback

  _findStreamProject: (callback)=>
    Project.findById @stream._project, (err, @project)=>
      callback(err)

  _mkProjectDir: (callback)=>
    return callback('project not found') unless @project
    makeFtpDirectory @ftpClient, @_projectDir(), callback

  _projectDir: ->
    streamFolder = @project.publicKey
    projectDir = "#{finalDirectory}/#{streamFolder}"

  _uploadToProjectDir: (callback)=>
    ftpLocation = "#{@_projectDir()}/#{@fileName}"
    console.log("uploading file", @fullFilePath, ftpLocation)
    @ftpClient.put @fullFilePath, ftpLocation, callback

  _addRecordingToEdgecastRecordings: (callback)=>
    EdgecastRecordings.findOrCreate _edgecastStream: @stream._id, (err, streamRecordings, created)=>
      fs.stat @fullFilePath, (err, stats)=>
        newRecording =
          name: @fileName
          size: stats.size
          date: new Date
          vodBookkeeperTest: true

        streamRecordings.recordings.push newRecording
        streamRecordings.save (err)->
          callback(err)

  _deleteOriginal: (callback)=>
    fs.unlink @fullFilePath, callback

class VodBookkeeper
  constructor: (@fileName)->

  process: (callback)=>
    console.log("HELLO")
    @_findEdgecastStream (err, stream)=>
      return callback(err) if err
      return callback("stream not found") unless stream
      handler = new SaveStreamRecording(@fileName, stream)
      handler.process(callback)

  _findEdgecastStream: (callback)=>
    streamName = streamRecordingNameEnforcer.extractStreamNameFromDirectory(@fileName)
    query =
      streamName: streamName
      instanceName: EdgecastFtpInfo.vodDirectory
    EdgecastStream.findOne query, callback

# json options
#  file: full path to file
exports.jobProcessor = (job, done)->
  file = job.data.file
  return done("no file passed in") unless file
  fs.exists file, (exists)->
    return done("Could not find file #{file}") unless exists
    handler = new VodBookkeeper(file)
    handler.process (err, outputFile)->
      if err
        console.log("Could not process file", file, err)
        done(err)
      else
        console.log("processed file", file)
        done()

Base.processJobs 'vod_bookkeeper', exports.jobProcessor if runMe
