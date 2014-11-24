Base = require('./base')
Cine.config('connect_to_mongo')
fs = require('fs')
_ = require('underscore')
async = require('async')
runMe = !module.parent

streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
EdgecastRecordings = Cine.server_model('edgecast_recordings')
s3Client = Cine.server_lib('aws/s3_client')
VOD_BUCKET = Cine.config('variables/s3').vodBucket

class SaveStreamRecording
  constructor: (@fullFilePath, @stream)->
    @fileName = _.last(@fullFilePath.split('/'))

  process: (@callback)=>
    return @callback('stream not assigned to project') unless @stream._project
    waterfallCalls = [@_findStreamProject, @_uploadToS3ProjectDir, @_addRecordingToEdgecastRecordings, @_deleteOriginal, @_closeConnection]
    async.waterfall waterfallCalls, @callback

  _findStreamProject: (callback)=>
    Project.findById @stream._project, (err, @project)=>
      callback(err)

  _uploadToS3ProjectDir: (callback)=>
    s3Location = "cines/#{@project.publicKey}/#{@fileName}"
    console.log("uploading file to s3", @fullFilePath, s3Location)
    s3Client.uploadFile @fullFilePath, VOD_BUCKET, s3Location, callback

  _addRecordingToEdgecastRecordings: (callback)=>
    EdgecastRecordings.findOrCreate _edgecastStream: @stream._id, (err, streamRecordings, created)=>
      fs.stat @fullFilePath, (err, stats)=>
        newRecording =
          name: @fileName
          size: stats.size
          date: new Date

        streamRecordings.recordings.push newRecording
        streamRecordings.save (err)->
          callback(err)

  _deleteOriginal: (callback)=>
    fs.unlink @fullFilePath, callback

  _closeConnection: (callback)=>
    callback()

class VodBookkeeper
  constructor: (@fileName)->

  process: (callback)=>
    @_findEdgecastStream (err, stream)=>
      return callback(err) if err
      return callback("stream not found") unless stream
      handler = new SaveStreamRecording(@fileName, stream)
      handler.process(callback)

  _findEdgecastStream: (callback)=>
    streamName = streamRecordingNameEnforcer.extractStreamNameFromDirectory(@fileName)
    query =
      streamName: streamName
    EdgecastStream.findOne query, callback

# json options
#  file: full path to file
exports.jobProcessor = (job, done)->
  console.log("running job", job.data)
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
