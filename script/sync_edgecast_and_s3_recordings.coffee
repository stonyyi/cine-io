environment = require('../config/environment')
Cine.config('connect_to_mongo')
fs = require('fs')
async = require('async')
_ = require('underscore')
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
s3Client = Cine.server_lib('aws/s3_client')
moment = require('moment')

VOD_BUCKET = "cine-io-vod"

FILES_TO_SKIP = [
  'lk3koZUnbl.1.mp4'
  'xkMOUbRPZl.10.mp4'
  'xkMOUbRPZl.15.mp4'
  'l1cgwV1Pex.1.mp4'
  'l1cgwV1Pex.3.mp4'
  'xkqP2_asJx.2.mp4'
  'Z1X2MbDHE.1412775837755.mp4'
]

logMe = (args...)->
  console.log(new Date, args...)

endFunction = (err, aggregate)->
  if err
    logMe("ending err", err)
    process.exit(1)
  process.exit(0)

class EnsureRecordingsOnS3
  constructor: (@publicKey)->

  process: (recordingList, callback)=>
    directory = "cines/#{@publicKey}/"
    lister = s3Client.list(VOD_BUCKET, directory)
    edgecastRecordingFiles = _.chain(recordingList).filter(isFile).pluck('name').value()
    existingS3Keys = []
    lister.on 'data', (data)->
      logMe("got data", data)
      _.each data.Contents, (item)->
        existingS3Keys.push item.Key.replace(directory,'')

    lister.on 'end', =>
      logMe("GOT KEYS", existingS3Keys)
      keysToUpload = _.difference(edgecastRecordingFiles, existingS3Keys)
      keysToUpload = _.difference(keysToUpload, FILES_TO_SKIP)
      logMe("PROCESSING KEYS", keysToUpload)
      async.eachSeries keysToUpload, @_processRecording, callback


  _processRecording: (recordingName, callback)=>
    outputFile = Cine.path("tmp/edgecast_recordings/#{recordingName}")
    vodFile = "cines/#{@publicKey}/#{recordingName}"
    @_downloadRecording recordingName, outputFile, (err)->
      return callback(err) if err
      logMe("uploading to s3", outputFile, vodFile)
      s3Client.uploadFile outputFile, VOD_BUCKET, vodFile, (err)->
        if err
          logMe("UPLOADED with err", err, vodFile)
        else
          logMe("UPLOADED", vodFile)
        fs.unlink outputFile, callback

  _downloadRecording: (recordingName, outputFile, callback)->
    ftpClient.get "/cines/#{@publicKey}/#{recordingName}", (err, stream)->
      logMe("streaming to outputfile", recordingName, outputFile)
      return callback(err) if err

      stream.once 'readable', ->
        logMe("Ready to read data", recordingName)
      stream.once 'close', callback

      stream.pipe(fs.createWriteStream(outputFile))

syncWithS3 = (ftpItem, callback)->
  publicKey = ftpItem.name
  logMe("Processing", publicKey)
  ftpClient.list "/cines/#{publicKey}", (err, recordingList)->
    return callback(err) if err
    logMe("recordingList", recordingList)
    ensureRecordingOnS3 = new EnsureRecordingsOnS3(publicKey)
    ensureRecordingOnS3.process recordingList, callback

isDirectory = (ftpItem)->
  ftpItem.type == 'd'
isFile = (ftpItem)->
  ftpItem.type == '-'

processStreamList = (err, publicKeyList)->
  return endFunction(err) if err
  logMe("publicKeyList", publicKeyList)
  publicKeyList = _.filter publicKeyList, isDirectory
  async.eachSeries publicKeyList, syncWithS3, (err)->
    console.log("DONE processing all publicKeys")
    endFunction(err)

beingSync = ->
  logMe("HELLO")
  ftpClient.list "/cines", processStreamList

ftpClient = edgecastFtpClientFactory(endFunction, beingSync)
