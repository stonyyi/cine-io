edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')

module.exports = (stream, recordingName, done)->

  endClient = (err) ->
    ftpClient.end()
    done(err)

  deleteRecording = ->
    ftpClient.delete "/#{stream.instanceName}/#{recordingName}", endClient

  ftpClient = edgecastFtpClientFactory done, deleteRecording
