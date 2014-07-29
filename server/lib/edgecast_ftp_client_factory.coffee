FtpClient = require('ftp')

edgecastFtpClientFactory = (originalCallback, readyCallback)->
  ftpClient = edgecastFtpClientFactory.builder()

  ftpClient.on "ready", readyCallback

  ftpClient.on "error", (error)->
    console.log("FTP ERROR", error)
    originalCallback(error)

  ftpClient.on "end", ->
    console.log("FTP END")

  ftpClient.on "greeting", (msg)->
    console.log('got ftp greeting', msg)

  ftpClient.connect Cine.config('variables/edgecast').ftp
  return ftpClient

edgecastFtpClientFactory.builder = ->
  new FtpClient

module.exports = edgecastFtpClientFactory
