path = require('path')
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

exports.extractStreamNameFromDirectory = (fullFilePath)->
  parts = fullFilePath.split('/')
  exports.extractStreamName _.last(parts)


hlsFileNameRegexp = /(.+)(?:-\d{13})/
# https://cine-io-hls.s3.amazonaws.com/some-stream-1416271565425.ts
exports.extractStreamNameFromHlsFile = (hlsFileName)->
  hlsFile = path.basename(hlsFileName, '.ts')
  matches =  hlsFile.match(hlsFileNameRegexp)
  return null unless matches
  return null unless _.isArray(matches)
  return matches[1]

# abc_123.mp4 => abc_123
# abc_1234.mp4 => abc
# abc.mp4 => abc
# abc.12.mp4 => abc
exports.extractStreamName = (fileName)->
  streamNameBeforeDot = fileName.split('.')[0]
  hasFourTrailingNumbers = streamNameBeforeDot.match(trailingFourNumbersAfterAnUnderscore)
  if hasFourTrailingNumbers then hasFourTrailingNumbers[1] else streamNameBeforeDot
