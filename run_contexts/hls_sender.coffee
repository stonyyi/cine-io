Base = require('./base')
Cine.config('connect_to_mongo')
fs = require('fs')
path = require 'path'
async = require 'async'
_ = require 'underscore'
runMe = !module.parent

noop=->

EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')
client = Cine.server_lib('redis_client')
uploadFileToS3 = Cine.server_lib('./upload_file_to_s3')

module.exports = hlsSender = (event, filename, callback=noop)->
  console.log('event is: ' + event)
  return callback() unless filename && path.extname(filename) == '.m3u8'
  checkAndUpdateM3U8 filename, (err)->
    console.log("DONE!", err)
    callback(err)

hlsSender._hlsDirectory = process.env.HLS_DIRECTORY || "/Users/thomas/work/tmp/hls"
# finalDirectory = "/Users/thomas/work/tmp"

s3Bucket = Cine.config('variables/s3').hlsBucket
cloudFrontURL = Cine.config('variables/s3').hlsCloudfrontUrl

uploadTSFileToS3 = (tsFilename, project, callback)->
  fullPath = path.join(hlsSender._hlsDirectory, tsFilename)
  uploadFileToS3(fullPath, s3Bucket, "#{project.publicKey}/#{tsFilename}", callback)

isTSFile = (line)->
  path.extname(line) == '.ts'

lastTSFile = (fileContents)->
  lines = fileContents.split("\n").reverse()
  _.find lines, isTSFile

projectForTSFile = (tsFile, callback)->
  streamName = streamRecordingNameEnforcer.extractStreamNameFromHlsFile(tsFile)
  query =
    streamName: streamName
  EdgecastStream.findOne query, (err, stream)->
    return callback(err) if err
    return callback("stream not found") unless stream

    Project.findById stream._project, (err, project)->
      return callback(err, stream) if err
      return callback("project not found", stream) unless project
      callback(null, stream, project)


modifyM3U8FileForCloudfront = (fileContents, project)->
  prependCloudfrontAndProjectToTSFile = (m3u8Line)->
    return m3u8Line if !isTSFile(m3u8Line)
    "#{cloudFrontURL}#{project.publicKey}/#{m3u8Line}"
  _.chain(fileContents.split("\n")).map(prependCloudfrontAndProjectToTSFile).value().join("\n")


redisKeyForStream = (project, stream)->
  "hls:#{project.publicKey}/#{stream.streamName}.m3u8"

addHLSFileToRedis = (fileContents, stream, project, callback)->
  redisKey = redisKeyForStream(project, stream)
  cloudfrontM3U8 = modifyM3U8FileForCloudfront(fileContents, project)
  console.log("Setting redis", redisKey, cloudfrontM3U8)
  client.set(redisKey, cloudfrontM3U8, callback)

updatesS3withNewTSFiles = (filename, fileContents, callback)->
  tsFile = lastTSFile(fileContents)
  console.log("Found ts files", tsFile)
  return callback("no ts files found") unless tsFile
  projectForTSFile tsFile, (err, stream, project)->
    return callback(err) if err
    asyncCalls =
      uploadToS3: (callback)->
        uploadTSFileToS3(tsFile, project, callback)
      updateRedisHLS: (callback)->
        addHLSFileToRedis(fileContents, stream, project, callback)
    async.series asyncCalls, (err)->
      console.log("uploaded ts files", err)
      callback(err)

# prependTSLocationToTSFile = (m3u8Line)->
#   return m3u8Line if !isTSFile(m3u8Line)
#   "#{cloudFrontURL}#{m3u8Line}"

# prependTSLocations = (fileContents)->
#   _.chain(fileContents.split("\n")).map(prependTSLocationToTSFile).value().join("\n")

# writeNewM3U8 = (filename, fileContents, callback)->
#   newM3U8FileContents = prependTSLocations(fileContents)
#   fullPath = path.join(finalDirectory, "new-#{filename}")

#   fs.writeFile fullPath, newM3U8FileContents, (err)->
#     callback("wrote new m3u8", err)

checkAndUpdateM3U8 = (filename, callback)->
  fullPath = path.join(hlsSender._hlsDirectory, filename)
  console.log("fullPath", fullPath)
  fs.readFile fullPath, (err, contents)->
    return callback(err) if err
    contents = contents.toString()
    console.log("Contents of ", filename, contents)

    updatesS3withNewTSFiles filename, contents, callback
      # return callback(err) if err
      # console.log("Writing local m3u8")
      # writeNewM3U8 filename, contents, (err)->
      #   return callback(err) if err
      #   callback()

Base.watch hlsSender._hlsDirectory, hlsSender if runMe

console.log("starting hls-uploader. watching:", hlsSender._hlsDirectory)
