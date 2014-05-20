spawn = require('child_process').spawn
parseEdgecastLog = Cine.server_lib('reporting/parse_edgecast_log')
fs = require('fs')

module.exports = (fileName, callback)->
  console.log('unzipping', fileName)
  unZipFile = fileName.slice(0, fileName.length-3)
  ls = spawn 'gunzip', [fileName]
  removeZippedFile = (err)->
    fs.unlink unZipFile, (unlinkErr)->
      console.error("ERROR unlinking file", unlinkErr) if err
      callback(err)
  ls.on 'close', ->
    parseEdgecastLog unZipFile, removeZippedFile
