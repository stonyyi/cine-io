mkdirp = require('mkdirp')
_ = require('underscore')
_str = require('underscore.string')
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')

getStreamArchiveList = (stream, done)->

  processStreamList = (err, list) ->
    streamArchives = _.filter list, (listItem)->
      _str.startsWith(listItem.name, stream.streamName)
    done(null, streamArchives)
    ftpClient.end()

  fetchStreamList = ->
    ftpClient.list "/#{stream.instanceName}", processStreamList

  ftpClient = edgecastFtpClientFactory done, fetchStreamList

module.exports = getStreamArchiveList
