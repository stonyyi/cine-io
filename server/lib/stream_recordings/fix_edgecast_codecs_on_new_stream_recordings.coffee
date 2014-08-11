async = require('async')
_ = require('underscore')
mkdirp = require('mkdirp')
fs = require("fs")
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
createNewStreamInEdgecast = Cine.server_lib('create_new_stream_in_edgecast')
recordingDir = "/#{createNewStreamInEdgecast.instanceName}"
directoryType = 'd'
fileType = '-'
processedPath = "/processed"
downloadDirectory = "#{Cine.root}/tmp/edgecast_recordings/"
fixedDirectory = "#{Cine.root}/tmp/fixed_edgecast_recordings/"
# transcodeRecording = Cine.server_lib("stream_recordings/transcode_recording")
makeFtpDirectory = Cine.server_lib("stream_recordings/make_ftp_directory")
nextStreamRecordingNumber = Cine.server_lib('stream_recordings/next_stream_recording_number')

ftpFixedDirectory = "/fixed_recordings"

# TODO DELETE THIS ONCE TRANSCODING IS READY
temporarilyJustMoveRecording = fs.link
transcodeRecording = temporarilyJustMoveRecording

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
      makeFtpDirectory @ftpClient, ftpFixedDirectory, (err)=>
        return callback(err) if err
        @ftpClient.list ftpFixedDirectory, (err, files)=>
          return callback(err) if err
          newFileName = @recordingName
          totalFiles = nextStreamRecordingNumber(@recordingName, files)
          if totalFiles > 0
            newFileName = @recordingName.split('.')[0]
            newFileName += ".#{totalFiles}.mp4"

          ftpLocation = "#{ftpFixedDirectory}/#{newFileName}"
          @ftpClient.put transcodedFileName, ftpLocation, callback

    @ftpClient.get fullFTPName, (err, stream)->
      return callback(err) if err

      stream.once 'readable', ->
        console.log("Ready to read data", fullFTPName)

      stream.once 'close', =>
        transcodeRecording(downloadedFileName, transcodedFileName, uploadFixedFile)

      stream.pipe(fs.createWriteStream(downloadedFileName))

descendingDateSort = (ftpListItem)->
  return (new Date(ftpListItem.date)).getTime()

streamRecordingsCodecFixer = (done)->

  mkdirp.sync downloadDirectory
  mkdirp.sync fixedDirectory

  transcodeEachNewFile = (ftpRecordingEntry, callback)->
    recordingHandler = new DownloadAndProcessRecording(ftpClient, ftpRecordingEntry)
    recordingHandler.process(callback)

  finish = (err)->
    ftpClient.end()
    done(err)

  findNewRecordingsAndMoveThemToStreamFolder = (err, list) ->
    return done(err) if err

    allFiles = _.chain(list).where(type: fileType).sortBy(descendingDateSort).value()

    console.log("No files to process.") if allFiles.length == 0

    async.eachSeries allFiles, transcodeEachNewFile, finish

  fetchStreamList = ->
    ftpClient.list recordingDir, findNewRecordingsAndMoveThemToStreamFolder

  ftpClient = edgecastFtpClientFactory done, fetchStreamList

module.exports = streamRecordingsCodecFixer
module.exports.processedPath = processedPath
