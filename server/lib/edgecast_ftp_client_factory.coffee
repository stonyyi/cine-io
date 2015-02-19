FtpClient = require('ftp')
debug = require('debug')('cine:edgecast_ftp_client_factory')

edgecastFtpClientFactory = (originalCallback, readyCallback)->
  ftpClient = edgecastFtpClientFactory.builder()
  calledBack = false
  ftpClient.on "ready", ->
    calledBack = true
    readyCallback()

  ftpClient.on "error", (error)->
    debug("FTP ERROR", error)
    calledBack = true
    originalCallback(error)

  ftpClient.on "end", ->
    debug("FTP END")
    return originalCallback("ended before ready or error") unless calledBack

  ftpClient.on "greeting", (msg)->
    debug('got ftp greeting', msg)

  ftpClient.connect Cine.config('variables/edgecast').ftp
  return ftpClient

edgecastFtpClientFactory.builder = ->
  new FtpClient

module.exports = edgecastFtpClientFactory
