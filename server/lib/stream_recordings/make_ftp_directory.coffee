debug = require('debug')('cine:make_ftp_directory')
directoryAlreadyExistsError = (err)->
  err.message == "Can't create directory: File exists" && err.code == 550

module.exports = (ftpClient, directory, callback)->
  ftpClient.mkdir directory, (err)->
    # there's no "ensure directory"
    # so just mkdir then catch a directory already exists
    if err && !directoryAlreadyExistsError(err)
      debug("mkdir error", err)
      return callback(err)
    callback()
