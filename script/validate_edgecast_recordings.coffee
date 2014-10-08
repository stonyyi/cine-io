# This goes through all edgecast recordings on edgecast
# and checks them against our local db.
# It will update any recording entry that it finds.
# It will then check all the recordings and make sure that
# there are associated edgecast recordings.
# It does this by keeping all recording ids in memory
# that it checks during the first pass
# and compares that to the entire list

environment = require('../config/environment')
Cine = require '../config/cine'
async = require('async')
_ = require('underscore')
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
Project = Cine.server_model('project')
EdgecastRecordings = Cine.server_model('edgecast_recordings')
EdgecastStream = Cine.server_model('edgecast_stream')
streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')

done = (err)->
  if err
    console.log("DONE ERR", err)
    process.exit(1)
  process.exit()

directoryType = 'd'

processedEdgecastRecordingIds = {}

# removes directories, and groups by streamName ie abc.12.mp4 goes into group abc
groupByStreamName = (list)->
  _.chain(list).where(type: '-').groupBy((listItem)->
    streamRecordingNameEnforcer.extractStreamName(listItem.name)
  ).pairs().value()

findRecordingsMissingInListOne = (listOne, listTwo)->
  missingSavedInDb = _.reject listOne, (firstItem)->
    matchingSavedRecording = _.find listTwo, (secondItem)->
      secondItem.name == firstItem.name &&
      secondItem.size == firstItem.size
      secondItem.date.toString() == firstItem.date.toString()
    matchingSavedRecording?

removeUnnecessaryRecordings = (edgecastRecordings, missingInEdgecast, callback)->
  _.invoke missingInEdgecast, 'remove'
  edgecastRecordings.save callback


addNewRecordingsToDB = (edgecastRecordingsInDb, missingSavedInDb, callback)->
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
    missingInEdgecast = findRecordingsMissingInListOne(savedRecordingsList, edgecastStreamRecordingsList)
    console.log("missingInEdgecast", missingInEdgecast)
    if (missingInEdgecast.length == 0)
      console.log("something is totally weird with this list", savedRecordingsList, edgecastStreamRecordingsList)
    err = "too many saved recordings"
    console.log("ERROR", err)
    return removeUnnecessaryRecordings(edgecastRecordingsInDb, missingInEdgecast, callback)
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
    EdgecastRecordings.findOne _edgecastStream: stream._id, (err, recordings)->
      processedEdgecastRecordingIds[recordings._id.toString()] = true
      return callback(err) if err
      unless recordings
        console.error("no recordings for stream", stream._id)
        return callback()
      # console.log("got recordings", recordings)
      validateSameRecordings(edgecastStreamRecordingsList, recordings, callback)

validateEveryRecording = (directory, callback)->
  console.log("processing", directory.name)
  ftpClient.list "/cines/#{directory.name}", (err, recordingsList)->
    return callback(err) if err
    async.eachSeries groupByStreamName(recordingsList), validateStreamRecordings, callback

ensureWeProcessedEveryRecording = (err)->
  return done(err) if err
  EdgecastRecordings.find {}, '_id', (err, recordings)->
    return done(err) if err
    edgecastRecordingIdsFromDb = _.chain(recordings).pluck('_id').invoke('toString').value().sort()
    processedRecordings = _.keys(processedEdgecastRecordingIds).sort()
    # happy case
    if _.isEqual(edgecastRecordingIdsFromDb, processedRecordings)
      console.log("Happily processed every #{processedRecordings.length} recordings entry. All complete!")
      return done()
    unprocessedRecordings = _.without(edgecastRecordingIdsFromDb, processedRecordings...)
    console.log("edgecastRecordingIdsFromDb", edgecastRecordingIdsFromDb)
    console.log("processedRecordings", processedRecordings)
    console.log("did not process unprocessedRecordings", unprocessedRecordings)
    done("DID NOT PROCESS EVERYTHING")

goThroughEveryDirectory = (err, list) ->
  return done(err) if err

  allDirectories = _.chain(list).where(type: directoryType).value()

  console.log("No directories.") if allDirectories.length == 0

  async.eachSeries allDirectories, validateEveryRecording, ensureWeProcessedEveryRecording

processAllRecodings = ->
  ftpClient.list "/cines", goThroughEveryDirectory

ftpClient = edgecastFtpClientFactory done, processAllRecodings
