spawn = require('child_process').spawn
parseEdgecastLog = Cine.server_lib('reporting/parse_edgecast_log')
fs = require('fs')
async = require('async')

module.exports = (gzippedFileName, callback)->
  console.log('unzipping', gzippedFileName)
  unZipFile = gzippedFileName.slice(0, gzippedFileName.length-3)
  upzipProcess = spawn 'gunzip', [gzippedFileName]
  removeZippedFile = (err)->
    return callback(err) if err
    asyncCalls =
      unlinkLogFile: (cb)->
        fs.unlink unZipFile, cb
    async.parallel asyncCalls, callback
  upzipProcess.on 'close', ->
    parseEdgecastLog unZipFile, removeZippedFile
