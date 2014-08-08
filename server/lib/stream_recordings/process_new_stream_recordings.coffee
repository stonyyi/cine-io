_ = require('underscore')
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
createNewStreamInEdgecast = Cine.server_lib('create_new_stream_in_edgecast')
async = require('async')
EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastRecordings = Cine.server_model('edgecast_recordings')
Project = Cine.server_model('project')
numberOfStreamRecordings = Cine.server_lib('stream_recordings/number_of_stream_recordings')

recordingDir = "/#{createNewStreamInEdgecast.instanceName}"
directoryType = 'd'
fileType = '-'


directoryAlreadyExistsError = (err)->
  err.message == "Can't create directory: File exists" && err.code == 550

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

    @ftpClient.mkdir @_projectDir(), (err)->
      # there's no "ensure directory"
      # so just mkdir then catch a directory already exists
      if err && !directoryAlreadyExistsError(err)
        console.log("mkdir error", err)
        return callback(err)
      callback()

  _ensureNewRecordingHasUniqueName: (callback)=>
    @newFileName = @fileName
    @ftpClient.list @_projectDir(), (err, files)=>
      return callback(err) if err
      totalFiles = numberOfStreamRecordings(@fileName, files)
      if totalFiles > 0
        newFileName = @fileName.split('.')[0]
        newFileName += ".#{totalFiles}.mp4"
        @newFileName = newFileName
      callback()

  _moveRecordingToProjectFolder: (callback)=>
    newName = "#{@_projectDir()}/#{@newFileName}"
    oldName = "#{recordingDir}/#{@fileName}"
    console.log("moving", oldName, newName)

    @ftpClient.rename oldName, newName, callback

  _projectDir: ->
    streamFolder = @project.publicKey
    projectDir = "#{recordingDir}/#{streamFolder}"

  _addRecordingToEdgecastRecordings: (callback)=>
    EdgecastRecordings.findOrCreate _edgecastStream: @stream._id, (err, streamRecordings, created)=>

      newRecording =
        name: @fileName
        size: @ftpRecordingEntry.size
        date: @ftpRecordingEntry.date

      streamRecordings.recordings.push newRecording
      streamRecordings.save callback

class RemoveStreamRecording
  constructor: (@ftpClient, @ftpRecordingEntry, @stream)->
    @fileName = @ftpRecordingEntry.name

  process: (callback)=>
    fullPath = "#{recordingDir}/#{@fileName}"
    console.log("Deleting", fullPath)
    @ftpClient.delete fullPath, callback

class NewRecordingHandler
  constructor: (@ftpClient, @ftpRecordingEntry)->
    @fileName = @ftpRecordingEntry.name

  process: (callback)=>
    @_findEdgecastStream (err, stream)=>
      return callback(err) if err
      return callback("stream not found") unless stream
      HandlerClass = if stream.record then SaveStreamRecording else RemoveStreamRecording
      handler = new HandlerClass(@ftpClient, @ftpRecordingEntry, stream)
      handler.process(callback)

  _findEdgecastStream: (callback)=>
    streamName = @fileName.split('.')[0]
    query =
      streamName: streamName
      instanceName: createNewStreamInEdgecast.instanceName
    EdgecastStream.findOne query, callback


descendingDateSort = (ftpListItem)->
  return (new Date(ftpListItem.date)).getTime()

processNewStreamRecordings = (done)->

  moveNewRecordingsToProjectFolder = (ftpRecordingEntry, callback)->
    recordingHandler = new NewRecordingHandler(ftpClient, ftpRecordingEntry)
    recordingHandler.process(callback)

  finish = (err)->
    ftpClient.end()
    done(err)

  findNewRecordingsAndMoveThemToStreamFolder = (err, list) ->
    return done(err) if err

    allFiles = _.chain(list).where(type: fileType).sortBy(descendingDateSort).value()

    console.log("No files to move.") if allFiles.length == 0

    async.eachSeries allFiles, moveNewRecordingsToProjectFolder, finish

  fetchStreamList = ->
    ftpClient.list recordingDir, findNewRecordingsAndMoveThemToStreamFolder

  ftpClient = edgecastFtpClientFactory done, fetchStreamList

module.exports = processNewStreamRecordings
