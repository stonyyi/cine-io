environment = require('../config/environment')
Cine = require '../config/cine'
async = require('async')
_ = require('underscore')
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
Project = Cine.server_model('project')
EdgecastRecordings = Cine.server_model('edgecast_recordings')
EdgecastStream = Cine.server_model('edgecast_stream')

done = (err)->
  if err
    console.log("DONE ERR", err)
    process.exit(1)
  process.exit()

directoryType = 'd'

# removes directories, and groups by streamName ie abc.12.mp4 goes into group abc
groupByStreamName = (list)->
  _.chain(list).where(type: '-').groupBy((listItem)->
    listItem.name.split('.')[0]
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

validateSameRecordings = (edgecastStreamRecordingsList, edgecastRecordingsInDb, callback)->
  savedRecordingsList = edgecastRecordingsInDb.recordings
  console.log("total recordings", edgecastStreamRecordingsList.length)
  missingSavedInDb = findRecordingsMissingInListOne(edgecastStreamRecordingsList, savedRecordingsList)
  if missingSavedInDb.length > 0
    console.log("missingSavedInDb", missingSavedInDb)
    err = "not all recordings saved in db"
    console.log("ERROR", err)
  else if savedRecordingsList.length > edgecastStreamRecordingsList.length
    missingInEdgecast = findRecordingsMissingInListOne(savedRecordingsList, edgecastStreamRecordingsList)
    console.log("missingInEdgecast", missingInEdgecast)
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

goThroughEveryDirectory = (err, list) ->
  return done(err) if err

  allDirectories = _.chain(list).where(type: directoryType).value()

  console.log("No directories.") if allDirectories.length == 0

  async.eachSeries allDirectories, validateEveryRecording, done

processAllRecodings = ->
  ftpClient.list "/cines", goThroughEveryDirectory

ftpClient = edgecastFtpClientFactory done, processAllRecodings
