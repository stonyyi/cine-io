_ = require('underscore')
_str = require('underscore.string')

module.exports = (fileName, ftpFileList)->
  streamName = fileName.split('.')[0]
  countByNameMatch = (accum, file)->
    return accum unless _str.startsWith(file.name, streamName)
    accum + 1

  _.inject(ftpFileList, countByNameMatch, 0)
