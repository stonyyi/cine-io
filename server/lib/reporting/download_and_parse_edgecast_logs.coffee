FtpClient = require('ftp')
async = require('async')
fs = require("fs")
_ = require('underscore')
mkdirp = require('mkdirp')
parseEdgecastLog = Cine.server_lib('reporting/unzip_and_process_edgecast_log')
EdgecastParsedLog = Cine.server_model('edgecast_parsed_log')

parseLogFile = (logName, outputFile, callback)->
  parsedLog = new EdgecastParsedLog(hasStarted: true, logName: logName)
  parsedLog.save (err)->
    return callback(err) if err
    parseEdgecastLog outputFile, (err)->
      if err
        parsedLog.parseError = err
      else
        parsedLog.isComplete = true
      parsedLog.save (err)->
        return callback(err) if err
        callback()

module.exports = (done)->
  directory = "#{Cine.root}/tmp/edgecast_logs/"
  mkdirp.sync directory
  ftpClient = new FtpClient

  processEdgecastLogFile = (logName, callback)->
    # console.log(logName)
    outputFile = "#{directory}#{logName}"

    ftpClient.get "/logs/#{logName}", (err, stream)->
      return callback(err) if err
      # stream.once 'readable', ->
      #   console.log("Ready to read data", logName)
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
        async.eachLimit toProcess, 1, processEdgecastLogFile, (err)->
          return done(err) if err
          ftpClient.end()

  ftpClient.on "error", (error)->
    done(error)

  ftpClient.on "end", ->
    done()

  # ftpClient.on "greeting", (msg)->
  #   console.log('msg', msg)

  ftpClient.connect Cine.config('variables/edgecast').ftp
