_ = require('underscore')
_str = require('underscore.string')

allNumber = /^\d+$/

module.exports = (fileName, ftpFileList)->
  streamName = fileName.split('.')[0]
  countByNameMatch = (largestValue, existingFile)->
    return largestValue unless _str.startsWith(existingFile.name, streamName)
    parts = existingFile.name.split('.')
    recordingNumber = parts[1]
    if allNumber.test(recordingNumber)
      number = Number(recordingNumber)
    else
      number = 0
    number += 1
    if number > largestValue then number else largestValue

  _.inject(ftpFileList, countByNameMatch, 0)
