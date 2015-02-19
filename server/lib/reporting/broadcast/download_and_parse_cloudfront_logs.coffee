debug = require('debug')('cine:download_and_parse_cloudfront_logs')
async = require('async')
fs = require("fs")
path = require("path")
_ = require('underscore')
mkdirp = require('mkdirp')
parseCloudfrontLog = Cine.server_lib('reporting/broadcast/parse_cloudfront_log')
unzipAndProcessFile = Cine.server_lib('reporting/unzip_and_process_file')
ParsedLog = Cine.server_model('parsed_log')
s3Client = Cine.server_lib('aws/s3_client')
s3Credentials = Cine.config('variables/s3')
LOG_BUCKET = s3Credentials.cloudfrontLogsBucket

parseLogFile = (logName, outputFile, callback)->
  parsedLog = new ParsedLog(hasStarted: true, logName: logName, source: 'cloudfront')
  parsedLog.save (err)->
    return callback(err) if err
    unzipAndProcessFile outputFile, parseCloudfrontLog, (err)->
      debug("parsed cloudfront log file", logName, err)
      parsedLog.parseErrors = err if err
      parsedLog.isComplete = true
      parsedLog.save (err)->
        callback(err)

batchS3Lister = (folder, dataCallback, doneCallback)->
  isEnded = false
  numData = 0
  doneProcessing = {}
  doneProcessing = ->
    _.every(_.values(doneProcessing), _.identity)

  lister = s3Client.list(LOG_BUCKET, folder)
  lister.on 'data', (data)->
    doneProcessing[numData] = false
    dataCallback data, (err)->
      doneProcessing[numData] = true
      doneCallback() if isEnded && doneProcessing()
  lister.on 'error', doneCallback
  lister.on 'end', ->
    isEnded = true
    doneCallback() if doneProcessing()

downloadAndParseEdgecastLogs = (done)->
  directory = "#{Cine.root}/tmp/cloudfront_logs/"
  mkdirp.sync directory

  processCloudfrontFile = (file, callback)->
    debug("PROCESSING", file)
    localPath = "#{directory}#{path.basename(file)}"
    s3Client.downloadFile localPath, LOG_BUCKET, file, (err)->
      if err
        debug("download error", err)
        return callback(err)
      parseLogFile file, localPath, callback

  processCloudfrontLogFiles = (data, callback)->
    files = _.pluck(data.Contents, 'Key')
    ParsedLog.find logName: {$in: files}, (err, parsedLogs)->
      return callback(err) if err
      parsedLogNames = _.pluck(parsedLogs, 'logName')
      toProcess = _.without(files, parsedLogNames...)
      async.each toProcess, processCloudfrontFile, callback

  processCloudfrontFolder = (folder, callback)->
    batchS3Lister folder, processCloudfrontLogFiles, callback

  # processCloudfrontFile("hls/publish-sfo1/EBXGNCBDF3ULO.2014-11-24-19.b5342c87.gz", done)
  processCloudfrontFolders = (data, callback)->
    folders = _.pluck(data.CommonPrefixes, 'Prefix')
    debug("PROCESSING hls folders", folders)
    async.each folders, processCloudfrontFolder, callback

  asyncCalls = [
    # hls log files are in sub directories based on hostname directory
    (callback)-> batchS3Lister('hls/', processCloudfrontFolders, callback)
    # vod log files are in a single directory
    (callback)-> batchS3Lister('vod/', processCloudfrontLogFiles, callback)
  ]
  async.series asyncCalls, done

module.exports = downloadAndParseEdgecastLogs
