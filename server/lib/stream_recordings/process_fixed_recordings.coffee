_ = require('underscore')
async = require('async')
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastRecordings = Cine.server_model('edgecast_recordings')
Project = Cine.server_model('project')
streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')
makeFtpDirectory = Cine.server_lib("stream_recordings/make_ftp_directory")
EdgecastFtpInfo = Cine.config('edgecast_ftp_info')

initialDirectory = "/#{EdgecastFtpInfo.readyToBeCatalogued}"
finalDirectory = "/#{EdgecastFtpInfo.vodDirectory}"

pickNameAndType = (item)->
  _.pick(item, 'name', 'type')

pickAllNameAndType = (list)->
  _.map(list, pickNameAndType)

class SaveStreamRecording
  constructor: (@ftpClient, @ftpRecordingEntry, @stream)->
    @fileName = @ftpRecordingEntry.name

  process: (callback)=>
    waterfallCalls = [@_findStreamProject, @_mkProjectDir, @_ensureNewRecordingHasUniqueName, @_moveRecordingToProjectFolder, @_addRecordingToEdgecastRecordings]
    async.series waterfallCalls, callback

  _findStreamProject: (callback)=>
    return callback('stream not assigned to project') unless @stream._project

    Project.findById @stream._project, (err, @project)=>
      callback(err)

  _mkProjectDir: (callback)=>
    return callback('project not found') unless @project
    makeFtpDirectory @ftpClient, @_projectDir(), callback

  _ensureNewRecordingHasUniqueName: (callback)=>
    @ftpClient.list @_projectDir(), (err, files)=>
      return callback(err) if err
      @newFileName = streamRecordingNameEnforcer.newFileName(@fileName, files)
      callback()

  _moveRecordingToProjectFolder: (callback)=>
    newName = "#{@_projectDir()}/#{@newFileName}"
    oldName = "#{initialDirectory}/#{@fileName}"
    console.log("moving", oldName, newName)

    @ftpClient.rename oldName, newName, callback

  _projectDir: ->
    streamFolder = @project.publicKey
    projectDir = "#{finalDirectory}/#{streamFolder}"

  _addRecordingToEdgecastRecordings: (callback)=>
    EdgecastRecordings.findOrCreate _edgecastStream: @stream._id, (err, streamRecordings, created)=>

      newRecording =
        name: @newFileName
        size: @ftpRecordingEntry.size
        date: @ftpRecordingEntry.date

      streamRecordings.recordings.push newRecording
      streamRecordings.save callback

class NewRecordingHandler
  constructor: (@ftpClient, @ftpRecordingEntry)->
    @fileName = @ftpRecordingEntry.name

  process: (callback)=>
    @_findEdgecastStream (err, stream)=>
      return callback(err) if err
      return callback("stream not found") unless stream
      handler = new SaveStreamRecording(@ftpClient, @ftpRecordingEntry, stream)
      handler.process(callback)

  _findEdgecastStream: (callback)=>
    streamName = streamRecordingNameEnforcer.extractStreamName(@fileName)
    query =
      streamName: streamName
      instanceName: EdgecastFtpInfo.vodDirectory
    EdgecastStream.findOne query, callback


descendingDateSort = (ftpListItem)->
  return (new Date(ftpListItem.date)).getTime()

processFixedRecordings = (done)->

  moveNewRecordingsToProjectFolder = (ftpRecordingEntry, callback)->
    recordingHandler = new NewRecordingHandler(ftpClient, ftpRecordingEntry)
    recordingHandler.process(callback)

  finish = (err)->
    ftpClient.end()
    done(err)

  findNewRecordingsAndMoveThemToStreamFolder = (err, list) ->
    return done(err) if err

    allFiles = _.chain(list).where(type: EdgecastFtpInfo.fileType).sortBy(descendingDateSort).value()
    console.log("No files to move.") if allFiles.length == 0

    async.eachSeries allFiles, moveNewRecordingsToProjectFolder, finish

  fetchStreamList = ->
    ftpClient.list initialDirectory, findNewRecordingsAndMoveThemToStreamFolder

  ftpClient = edgecastFtpClientFactory done, fetchStreamList

module.exports = processFixedRecordings
