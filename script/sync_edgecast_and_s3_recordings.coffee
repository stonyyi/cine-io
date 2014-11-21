environment = require('../config/environment')
Cine.config('connect_to_mongo')
fs = require('fs')
async = require('async')
_ = require('underscore')
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
s3Client = Cine.server_lib('aws/s3_client')

VOD_BUCKET = "cine-io-vod"

endFunction = (err, aggregate)->
  if err
    console.log("ending err", err)
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
      console.log("got data", data)
      _.each data.Contents, (item)->
        existingS3Keys.push item.Key.replace(directory,'')

    lister.on 'end', =>
      console.log("GOT KEYS", existingS3Keys)
      keysToUpload = _.difference(edgecastRecordingFiles, existingS3Keys)
      console.log("PROCESSING KEYS", keysToUpload)
      async.eachSeries keysToUpload, @_processRecording, callback


  _processRecording: (recordingName, callback)=>
    outputFile = Cine.path("tmp/edgecast_recordings/#{recordingName}")
    vodFile = "cines/#{@publicKey}/#{recordingName}"
    @_downloadRecording recordingName, outputFile, (err)=>
      return callback(err) if err
      console.log("uploading to s3", outputFile, vodFile)
      s3Client.uploadFile outputFile, VOD_BUCKET, vodFile, (err)->
        if err
          console.log("UPLOADED with err", err, vodFile)
        else
          console.log("UPLOADED", vodFile)
        fs.unlink outputFile, callback

  _downloadRecording: (recordingName, outputFile, callback)->
    ftpClient.get "/cines/#{@publicKey}/#{recordingName}", (err, stream)->
      console.log("streaming to outputfile", recordingName, outputFile)
      return callback(err) if err

      stream.once 'readable', ->
        console.log("Ready to read data", recordingName)
      stream.once 'close', callback

      stream.pipe(fs.createWriteStream(outputFile))

syncWithS3 = (ftpItem, callback)->
  publicKey = ftpItem.name
  console.log("Processing", publicKey)
  ftpClient.list "/cines/#{publicKey}", (err, recordingList)->
    return callback(err) if err
    console.log("recordingList", recordingList)
    ensureRecordingOnS3 = new EnsureRecordingsOnS3(publicKey)
    ensureRecordingOnS3.process recordingList, callback

isDirectory = (ftpItem)->
  ftpItem.type == 'd'
isFile = (ftpItem)->
  ftpItem.type == '-'

processStreamList = (err, publicKeyList)->
  return endFunction(err) if err
  console.log("publicKeyList", publicKeyList)
  publicKeyList = _.filter publicKeyList, isDirectory
  async.eachSeries publicKeyList, syncWithS3, endFunction

beingSync = ->
  console.log("HELLO")
  ftpClient.list "/cines", processStreamList

ftpClient = edgecastFtpClientFactory(endFunction, beingSync)
