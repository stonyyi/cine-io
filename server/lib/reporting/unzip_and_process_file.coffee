debug = require('debug')('cine:unzip_and_process_file')
spawn = require('child_process').spawn
fs = require('fs')
async = require('async')

module.exports = (gzippedFileName, unzippedFileFunction, done)->
  debug('unzipping', gzippedFileName)
  unZipFile = gzippedFileName.slice(0, gzippedFileName.length-3)
  upzipProcess = spawn 'gunzip', [gzippedFileName]
  removeZippedFile = (err)->
    return done(err) if err
    asyncCalls =
      unlinkLogFile: (cb)->
        fs.unlink unZipFile, cb
    async.parallel asyncCalls, done
  upzipProcess.on 'close', ->
    unzippedFileFunction unZipFile, removeZippedFile
