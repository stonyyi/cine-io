_ = require 'underscore'
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
EdgecastFtpInfo = Cine.config('edgecast_ftp_info')
Project = Cine.server_model("project")

exports.total = (project, done)->

  processStreamList = (err, list) ->
    # console.log("got directory", err, list)
    return done(err) if err
    sumSize = (accum, listItem)->
      accum + listItem.size
    totalSize = _.inject list, sumSize, 0
    ftpClient.end()
    done(null, totalSize)

  getProjectDirectoryStorage = ->
    directory = "/#{EdgecastFtpInfo.vodDirectory}/#{project.publicKey}"
    # console.log("Searching", directory)
    ftpClient.list directory, processStreamList

  ftpClient = edgecastFtpClientFactory done, getProjectDirectoryStorage
