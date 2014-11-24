# This goes through all edgecast recordings on s3
# and checks them against our local db.
# It will update any recording entry that it finds.
# It will then check all the recordings and make sure that
# there are associated edgecast recordings.
# It does this by keeping all recording ids in memory
# that it checks during the first pass
# and compares that to the entire list

environment = require('../config/environment')
Cine.config('connect_to_mongo')
async = require('async')
_ = require('underscore')
Project = Cine.server_model('project')
StreamRecordings = Cine.server_model('stream_recordings')
EdgecastStream = Cine.server_model('edgecast_stream')
streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')
s3Client = Cine.server_lib('aws/s3_client')
s3Credentials = Cine.config('variables/s3')

DRY_RUN = false

VOD_BUCKET = s3Credentials.vodBucket

logMe = (args...)->
  # console.log(new Date, args...)

endFunction = (err)->
  if err
    console.log("DONE ERR", err)
    process.exit(1)
  process.exit()

directoryType = 'd'

processedStreamRecordingIds = {}

# removes directories, and groups by streamName ie abc.12.mp4 goes into group abc
groupByStreamName = (list)->
  _.chain(list).groupBy((listItem)->
    streamRecordingNameEnforcer.extractStreamName(listItem.name)
  ).pairs().value()

findRecordingsMissingInListOne = (listOne, listTwo)->
  missingSavedInDb = _.reject listOne, (firstItem)->
    matchingSavedRecording = _.find listTwo, (secondItem)->
      secondItem.name == firstItem.name &&
      secondItem.size == firstItem.size
      # secondItem.date.toString() == firstItem.date.toString()
    matchingSavedRecording?

removeUnnecessaryRecordings = (edgecastRecordings, missingInS3, callback)->
  return callback() if DRY_RUN
  _.invoke missingInS3, 'remove'
  edgecastRecordings.save callback


addNewRecordingsToDB = (edgecastRecordingsInDb, missingSavedInDb, callback)->
  return callback() if DRY_RUN
  _.each missingSavedInDb, (recording)->

    edgecastRecordingsInDb.recordings.push
      name: recording.name
      size: recording.size
      date: recording.date

  edgecastRecordingsInDb.save callback

validateSameRecordings = (edgecastStreamRecordingsList, edgecastRecordingsInDb, callback)->
  savedRecordingsList = edgecastRecordingsInDb.recordings
  console.log("total recordings", edgecastStreamRecordingsList.length)
  missingSavedInDb = findRecordingsMissingInListOne(edgecastStreamRecordingsList, savedRecordingsList)
  if missingSavedInDb.length > 0
    console.log("missingSavedInDb", missingSavedInDb)
    err = "not all recordings saved in db"
    console.log("ERROR", err)
    return addNewRecordingsToDB(edgecastRecordingsInDb, missingSavedInDb, callback)
  else if savedRecordingsList.length > edgecastStreamRecordingsList.length
    missingInS3 = findRecordingsMissingInListOne(savedRecordingsList, edgecastStreamRecordingsList)
    console.log("missingInS3", missingInS3)
    if (missingInS3.length == 0)
      console.log("something is totally weird with this list", savedRecordingsList, edgecastStreamRecordingsList)
    err = "too many saved recordings"
    console.log("ERROR", err)
    return removeUnnecessaryRecordings(edgecastRecordingsInDb, missingInS3, callback)
  else if savedRecordingsList.length < edgecastStreamRecordingsList.length
    err = "recording list is totally fucked"
    console.log("ERROR", err)
  return callback()

validateStreamRecordings = (streamRecordingsTuple, callback)->
  streamName = streamRecordingsTuple[0]
  edgecastStreamRecordingsList = streamRecordingsTuple[1]
  # console.log('streamName', streamName)
  # console.log('edgecastStreamRecordingsList', edgecastStreamRecordingsList)
  EdgecastStream.findOne streamName: streamName, (err, stream)->
    return callback(err) if err
    unless stream
      console.error("stream not found", streamName)
      return callback()
    StreamRecordings.findOne _edgecastStream: stream._id, (err, recordings)->
      unless recordings
        console.error("no recordings for stream", stream._id)
        return callback()
      processedStreamRecordingIds[recordings._id.toString()] = true
      return callback(err) if err
      # console.log("got recordings", recordings)
      validateSameRecordings(edgecastStreamRecordingsList, recordings, callback)

validateEveryRecording = (publicKey, callback)->
  console.log("processing", publicKey)
  directory = "cines/#{publicKey}/"
  recordings = []
  lister = s3Client.list(VOD_BUCKET, directory)

  lister.on 'data', (data)->
    logMe("got data", data)

    _.each data.Contents, (item)->
      recordings.push name: item.Key.replace(directory,''), size: item.Size, date: item.LastModified

  lister.on 'end', ->
    logMe("GOT KEYS", recordings)
    grouped = groupByStreamName(recordings)
    logMe("GOT grouped", grouped)

    async.eachSeries grouped, validateStreamRecordings, callback

  # ftpClient.list "/cines/#{directory.name}", (err, recordingsList)->
  #   return callback(err) if err
  #   async.eachSeries groupByStreamName(recordingsList), validateStreamRecordings, callback

ensureWeProcessedEveryRecording = (err)->
  return endFunction(err) if err
  StreamRecordings.find {}, '_id', (err, recordings)->
    return endFunction(err) if err
    edgecastRecordingIdsFromDb = _.chain(recordings).pluck('_id').invoke('toString').value().sort()
    processedRecordings = _.keys(processedStreamRecordingIds).sort()
    # happy case
    if _.isEqual(edgecastRecordingIdsFromDb, processedRecordings)
      console.log("Happily processed every #{processedRecordings.length} recordings entry. All complete!")
      return endFunction()
    unprocessedRecordings = _.without(edgecastRecordingIdsFromDb, processedRecordings...)
    console.log("edgecastRecordingIdsFromDb", edgecastRecordingIdsFromDb)
    console.log("processedRecordings", processedRecordings)
    console.log("did not process unprocessedRecordings", unprocessedRecordings)
    endFunction("DID NOT PROCESS EVERYTHING")

goThroughPublicKeys = ->
  directory = 'cines/'
  lister = s3Client.list(VOD_BUCKET, directory)

  publicKeys = []
  lister.on 'data', (data)->
    logMe("got data", data)

    _.each data.CommonPrefixes, (item)->
      publicKeys.push item.Prefix.replace(directory,'').replace('/', '')

  lister.on 'end', ->
    logMe("GOT KEYS", publicKeys)

    console.log("No directories.") if publicKeys.length == 0

    async.eachSeries publicKeys, validateEveryRecording, ensureWeProcessedEveryRecording

goThroughPublicKeys()
