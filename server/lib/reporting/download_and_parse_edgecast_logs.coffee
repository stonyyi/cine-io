FtpClient = require('ftp')
async = require('async')
fs = require("fs")
_ = require('underscore')
mkdirp = require('mkdirp')
parseEdgecastLog = Cine.server_lib('reporting/unzip_and_process_edgecast_log')
EdgecastParsedLog = Cine.server_model('edgecast_parsed_log')

parseLogFile = (logName, outputFile, callback)->
  console.log("creating EdgecastParsedLog", logName)
  parsedLog = new EdgecastParsedLog(hasStarted: true, logName: logName)
  parsedLog.save (err)->
    return callback(err) if err
    parseEdgecastLog outputFile, (err)->
      console.log("parsed edgecast log file", logName, err)
      if err
        parsedLog.parseError = err
      else
        parsedLog.isComplete = true
      parsedLog.save (err)->
        callback(err)

downloadAndParseEdgecastLogs = (done)->
  directory = "#{Cine.root}/tmp/edgecast_logs/"
  mkdirp.sync directory
  ftpClient = downloadAndParseEdgecastLogs.ftpFactory()

  processEdgecastLogFile = (logName, callback)->
    console.log("parsing", logName)
    outputFile = "#{directory}#{logName}"

    ftpClient.get "/logs/#{logName}", (err, stream)->
      console.log("streaming to outputfile", logName, outputFile)

      return callback(err) if err
      stream.once 'readable', ->
        console.log("Ready to read data", logName)
      stream.once 'close', ->
        parseLogFile(logName, outputFile, callback)
      stream.pipe(fs.createWriteStream(outputFile))

  ftpClient.on "ready", ->
    ftpClient.list '/logs', (err, list) ->
      ftpLogNames = _.pluck(list, 'name')
      EdgecastParsedLog.find logName: {$in: ftpLogNames}, (err, parsedLogs)->
        return done(err) if err
        parsedLogNames = _.pluck(parsedLogs, 'logName')
        toProcess = _.without(ftpLogNames, parsedLogNames...)
        console.log("Going to process: ", toProcess)
        async.eachLimit toProcess, 1, processEdgecastLogFile, (err)->
          return done(err) if err
          ftpClient.end()

  ftpClient.on "error", (error)->
    console.log("FTP ERROR", error)
    done(error)

  ftpClient.on "end", ->
    console.log("FTP END")
    done()

  ftpClient.on "greeting", (msg)->
    console.log('got ftp greeting', msg)

  ftpClient.connect Cine.config('variables/edgecast').ftp

downloadAndParseEdgecastLogs.ftpFactory = ->
  new FtpClient

module.exports = downloadAndParseEdgecastLogs
