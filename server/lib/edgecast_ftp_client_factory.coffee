FtpClient = require('ftp')

edgecastFtpClientFactory = (originalCallback, readyCallback)->
  ftpClient = edgecastFtpClientFactory.builder()
  calledBack = false
  ftpClient.on "ready", ->
    calledBack = true
    readyCallback()

  ftpClient.on "error", (error)->
    console.log("FTP ERROR", error)
    calledBack = true
    originalCallback(error)

  ftpClient.on "end", ->
    console.log("FTP END")
    return originalCallback("ended before ready or error") unless calledBack

  ftpClient.on "greeting", (msg)->
    console.log('got ftp greeting', msg)

  ftpClient.connect Cine.config('variables/edgecast').ftp
  return ftpClient

edgecastFtpClientFactory.builder = ->
  new FtpClient

module.exports = edgecastFtpClientFactory
