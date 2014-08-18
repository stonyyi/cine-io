async = require('async')
_ = require('underscore')
mkdirp = require('mkdirp')
fs = require("fs")
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
createNewStreamInEdgecast = Cine.server_lib('create_new_stream_in_edgecast')
fixMP4Container = Cine.server_lib("stream_recordings/fix_mp4_container")
makeFtpDirectory = Cine.server_lib("stream_recordings/make_ftp_directory")
nextStreamRecordingNumber = Cine.server_lib('stream_recordings/next_stream_recording_number')
scheduleJob = Cine.server_lib('schedule_job')
EdgecastFtpInfo = Cine.config('edgecast_ftp_info')

recordingDir = "/#{EdgecastFtpInfo.readyToBeFixedDirectory}"
ftpOutputPath = "/#{EdgecastFtpInfo.readyToBeCatalogued}"
downloadDirectory = "#{Cine.root}/tmp/edgecast_recordings/"
fixedDirectory = "#{Cine.root}/tmp/fixed_edgecast_recordings/"

class DownloadAndProcessRecording
  constructor: (@ftpClient, @ftpRecordingEntry)->
    @recordingName = @ftpRecordingEntry.name

  process: (callback)->
    fullFTPName = "#{recordingDir}/#{@recordingName}"
    downloadedFileName = "#{downloadDirectory}#{@recordingName}"
    transcodedFileName = "#{fixedDirectory}#{@recordingName}"

    uploadFixedFile = (err)=>
      # 1. ensure recording_directory is there
      # 2. ensure our streamName has a unique incremental name
      # 3. upload the mp4 file
      makeFtpDirectory @ftpClient, ftpOutputPath, (err)=>
        return callback(err) if err
        @ftpClient.list ftpOutputPath, (err, files)=>
          return callback(err) if err
          newFileName = @recordingName
          totalFiles = nextStreamRecordingNumber(@recordingName, files)
          if totalFiles > 0
            newFileName = @recordingName.split('.')[0]
            newFileName += ".#{totalFiles}.mp4"

          ftpLocation = "#{ftpOutputPath}/#{newFileName}"
          @ftpClient.put transcodedFileName, ftpLocation, (err)=>
            return callback(err) if err
            @ftpClient.delete fullFTPName, callback

    @ftpClient.get fullFTPName, (err, stream)->
      return callback(err) if err

      stream.once 'readable', ->
        console.log("Ready to read data", fullFTPName)

      stream.once 'close', ->
        fixMP4Container(downloadedFileName, transcodedFileName, uploadFixedFile)

      stream.pipe(fs.createWriteStream(downloadedFileName))

descendingDateSort = (ftpListItem)->
  return (new Date(ftpListItem.date)).getTime()

streamRecordingsCodecFixer = (done)->

  mkdirp.sync downloadDirectory
  mkdirp.sync fixedDirectory
  scheduleFollowupJob = false

  transcodeEachNewFile = (ftpRecordingEntry, callback)->
    recordingHandler = new DownloadAndProcessRecording(ftpClient, ftpRecordingEntry)
    recordingHandler.process(callback)

  finish = (err)->
    ftpClient.end()
    return done(err) if err
    return done() unless scheduleFollowupJob
    scheduleJob 'stream_recordings/process_fixed_recordings', done

  findNewRecordingsAndMoveThemToStreamFolder = (err, list) ->
    return done(err) if err

    allFiles = _.chain(list).where(type: EdgecastFtpInfo.fileType).sortBy(descendingDateSort).value()

    if allFiles.length == 0
      console.log("No files to process.")
    else
      scheduleFollowupJob = true

    async.eachSeries allFiles, transcodeEachNewFile, finish

  fetchStreamList = ->
    ftpClient.list recordingDir, findNewRecordingsAndMoveThemToStreamFolder

  ftpClient = edgecastFtpClientFactory done, fetchStreamList

module.exports = streamRecordingsCodecFixer
module.exports.outputPath = ftpOutputPath
