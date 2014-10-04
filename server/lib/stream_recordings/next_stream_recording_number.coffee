_ = require('underscore')
_str = require('underscore.string')

allNumber = /^\d+$/
trailingFourNumbersAfterAnUnderscore = /^(.+)_\d{4}(\.mp4)?$/
nextStramRecordingNumber = (fileName, ftpFileList)->
  streamName = exports.extractStreamName(fileName)
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

exports.newFileName = (fileName, ftpFileList)->
  newFileName = fileName
  totalFiles = nextStramRecordingNumber(fileName, ftpFileList)
  if totalFiles > 0
    newFileName = exports.extractStreamName(fileName)
    newFileName += ".#{totalFiles}.mp4"
    newFileName = newFileName
  newFileName

# abc_123.mp4 => abc_123
# abc_1234.mp4 => abc
# abc.mp4 => abc
# abc.12.mp4 => abc
exports.extractStreamName = (fileName)->
  hasFourTrailingNumbers = fileName.match(trailingFourNumbersAfterAnUnderscore)
  return hasFourTrailingNumbers[1] if hasFourTrailingNumbers
  fileName.split('.')[0]
