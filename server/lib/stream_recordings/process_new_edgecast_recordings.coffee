# this library is in a cron job that does 2 things
# it sees if there are new recordings
# if the associated stream for this recording is set to true
# then it moves it into a folder to be fixed by our worker
# if the stream supposed to not save
# then delete the recording
_ = require('underscore')
async = require('async')
EdgecastStream = Cine.server_model('edgecast_stream')
makeFtpDirectory = Cine.server_lib("stream_recordings/make_ftp_directory")
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')
EdgecastFtpInfo = Cine.config('edgecast_ftp_info')
scheduleJob = Cine.server_lib('schedule_job')

recordingDir = "/#{EdgecastFtpInfo.vodDirectory}"
folderToFix = "/#{EdgecastFtpInfo.readyToBeFixedDirectory}"

class SaveStreamRecording
  constructor: (@ftpClient, @ftpRecordingEntry, @stream)->
    @fileName = @ftpRecordingEntry.name

  process: (callback)=>
    waterfallCalls = [@_mkFixFolder, @_ensureNewRecordingHasUniqueName, @_moveRecordingToProcessFolder]
    async.series waterfallCalls, (err)->
      return callback(err) if err
      callback(null, savedRecording: true)

  _mkFixFolder: (callback)=>
    makeFtpDirectory @ftpClient, folderToFix, callback

  _ensureNewRecordingHasUniqueName: (callback)=>
    @ftpClient.list folderToFix, (err, files)=>
      return callback(err) if err
      @newFileName = streamRecordingNameEnforcer.newFileName(@fileName, files)
      callback()

  _moveRecordingToProcessFolder: (callback)=>
    newName = "#{folderToFix}/#{@newFileName}"
    oldName = "#{recordingDir}/#{@fileName}"
    console.log("moving", oldName, newName)

    @ftpClient.rename oldName, newName, callback

class NewRecordingHandler
  constructor: (@ftpClient, @ftpRecordingEntry)->
    @fileName = @ftpRecordingEntry.name

  process: (callback)=>
    @_findEdgecastStream (err, stream)=>
      return callback(err) if err
      unless stream
        console.log("Stream not found", @fileName, @ftpRecordingEntry)
        return callback("stream not found")
      HandlerClass = if stream.record then SaveStreamRecording else RemoveStreamRecording
      handler = new HandlerClass(@ftpClient, @ftpRecordingEntry, stream)
      handler.process(callback)

  _findEdgecastStream: (callback)=>
    streamName = streamRecordingNameEnforcer.extractStreamName(@fileName)
    query =
      streamName: streamName
      instanceName: EdgecastFtpInfo.vodDirectory
    EdgecastStream.findOne query, callback

class RemoveStreamRecording
  constructor: (@ftpClient, @ftpRecordingEntry, @stream)->
    @fileName = @ftpRecordingEntry.name

  process: (callback)=>
    fullPath = "#{recordingDir}/#{@fileName}"
    console.log("Deleting", fullPath)
    @ftpClient.delete fullPath, callback

descendingDateSort = (ftpListItem)->
  return (new Date(ftpListItem.date)).getTime()

processNewEdgecastRecordings = (done)->
  newRecordingToProcess = false
  moveNewRecordingsToAppropriateFolder = (ftpRecordingEntry, callback)->
    recordingHandler = new NewRecordingHandler(ftpClient, ftpRecordingEntry)
    recordingHandler.process (err, options)->
      return callback(err) if err
      if options && options.savedRecording
        newRecordingToProcess = true
      callback()

  finish = (err)->
    ftpClient.end()
    return done(err) if err
    return done() unless newRecordingToProcess
    scheduleJob 'stream_recordings/fix_edgecast_codecs_on_new_stream_recordings', {}, {priority: 1}, done

  findNewRecordingsAndMoveThemToStreamFolder = (err, list) ->
    return done(err) if err

    allFiles = _.chain(list).where(type: EdgecastFtpInfo.fileType).sortBy(descendingDateSort).value()

    console.log("No new recordings to process.") if allFiles.length == 0

    async.eachSeries allFiles, moveNewRecordingsToAppropriateFolder, finish

  fetchStreamList = ->
    ftpClient.list recordingDir, findNewRecordingsAndMoveThemToStreamFolder

  ftpClient = edgecastFtpClientFactory done, fetchStreamList

module.exports = processNewEdgecastRecordings
