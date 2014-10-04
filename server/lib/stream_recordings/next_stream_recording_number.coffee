_ = require('underscore')
_str = require('underscore.string')

allNumber = /^\d+$/

nextStramRecordingNumber = (fileName, ftpFileList)->
  streamName = extractStreamName(fileName)
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
    newFileName = extractStreamName(fileName)
    newFileName += ".#{totalFiles}.mp4"
    newFileName = newFileName
  newFileName

exports.extractStreamName = (fileName)->
  fileName.split('.')[0]
