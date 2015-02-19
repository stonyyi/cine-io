spawn = require('child_process').spawn
fs = require('fs')

exports.createNewFile = (inFile, outFile, callback)->
  gzipProcess = spawn 'gzip', ["--stdout", inFile]
  logStream = fs.createWriteStream(outFile, {flags: 'w'})
  gzipProcess.stdout.pipe(logStream)
  gzipProcess.stderr.pipe(logStream)
  gzipProcess.on 'close', (code)->
    return callback(code) if code != 0
    callback()

exports.replaceFile = (inFile, callback)->
  gzipProcess = spawn 'gzip', ["--force", inFile]
  gzipProcess.on 'close', (code)->
    return callback(code) if code != 0
    callback()
