Base = require('./base')
Cine.config('connect_to_mongo')
fs = require('fs')
os = require('os')
path = require 'path'
async = require 'async'
_ = require 'underscore'
runMe = !module.parent
cloudfront = Cine.server_lib("aws/cloudfront")
noop=->

EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')
client = Cine.server_lib('redis_client')

redisKeyForM3U8 = Cine.server_lib('hls/redis_key_for_m3u8')
localHostname = os.hostname()
localUrl = "#{localHostname}.cine.io"

hlsSender = (event, filename, callback=noop)->
  return callback() unless filename && path.extname(filename) == '.m3u8'
  checkAndUpdateM3U8 filename, (err)->
    console.log("finished parsing", filename)
    console.error("got err checking m3u8", err) if err
    callback(err)

hlsSender._hlsDirectory = process.env.HLS_DIRECTORY || "/Users/thomas/work/tmp/hls"

hlsSender._cloudFrontURL = null #replaced by setupCloudfrontForHls
hlsSender._setupCloudfrontForHls = (callback=noop)->
  cloudfrontOptions =
    logging:
      bucket: 'cine-cloudfront-logging.s3.amazonaws.com'
      prefix: localHostname
  console.log("Ensuring cloudfront distro", localUrl, cloudfrontOptions)
  cloudfront.ensureDistributionForOrigin localUrl, (err, distribution)->
    return console.error("got err setting up cloudfront", err) if err
    return console.error("could not setup distribution") unless distribution
    hlsSender._cloudFrontURL = "#{distribution.DomainName}"
    console.log("Changing from local to cloudfront", localUrl, hlsSender._cloudFrontURL)
    callback()

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


modifyM3U8FileForCloudfront = (fileContents)->
  prependCloudfrontAndProjectToTSFile = (m3u8Line)->
    return m3u8Line if !isTSFile(m3u8Line)
    # use cloudfront once it is setup
    if hlsSender._cloudFrontURL
      "http://#{hlsSender._cloudFrontURL}/hls/#{m3u8Line}"
    else
      "http://#{localUrl}/hls/#{m3u8Line}"
  _.chain(fileContents.split("\n")).map(prependCloudfrontAndProjectToTSFile).value().join("\n")


addHLSFileToRedis = (fileContents, stream, project, callback)->
  redisKey = redisKeyForM3U8.withObjects(project, stream)
  cloudfrontM3U8 = modifyM3U8FileForCloudfront(fileContents)
  # console.log("Setting redis", redisKey, cloudfrontM3U8)
  client.set(redisKey, cloudfrontM3U8, callback)

updatesS3withNewTSFiles = (filename, fileContents, callback)->
  tsFile = lastTSFile(fileContents)
  # console.log("new ts file", tsFile)
  return callback("no ts files found") unless tsFile
  projectForTSFile tsFile, (err, stream, project)->
    return callback(err) if err
    addHLSFileToRedis(fileContents, stream, project, callback)


queueTask = (task, callback)->
  filename = task.filename
  fullPath = path.join(hlsSender._hlsDirectory, filename)
  console.log("parsing m3u8", fullPath)

  fs.readFile fullPath, (err, contents)->
    return callback(err) if err
    contents = contents.toString()
    # console.log("Contents of ", filename, contents)

    updatesS3withNewTSFiles filename, contents, callback

queues = {}
createNewQueue = (filename)->
  queue = async.queue queueTask, 1
  queue.drain = ->
    delete queues[filename]
  queue

getQueue = (filename)->
  queues[filename] ||= createNewQueue(filename)

checkAndUpdateM3U8 = (filename, callback)->
  queue = getQueue(filename)
  queue.push filename: filename, callback


Base.watch hlsSender._hlsDirectory, hlsSender if runMe

hlsSender._setupCloudfrontForHls() if process.env.NODE_ENV in ['production']

module.exports = hlsSender

# console.log("starting hls-uploader. watching:", hlsSender._hlsDirectory)
