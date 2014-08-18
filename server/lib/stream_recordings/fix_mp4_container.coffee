async = require('async')
exec = require('child_process').exec
fs = require('fs')
# ffmpeg -i input.mp4 -c:v copy -c:a copy output.mp4
# MP4Box -par 1=1:1 output.mp4

ffmpeg = "ffmpeg"
MP4Box = "MP4Box"

fileDoesNotExist = (err)->
  err.errno == 34 && err.code == 'ENOENT'

module.exports = (inputFile, outputFile, callback)->

  # ffmpeg will hang if the output file already exists
  ensureOutputEmpty = (callback)->
    fs.unlink outputFile, (err)->
      console.log("ensureOutputEmpty", err)
      return callback() if !err || fileDoesNotExist(err)
      callback(err)

  callFfmpeg = (callback)->
    cmd = "#{ffmpeg} -i #{inputFile} -c:v copy -c:a copy #{outputFile}"
    console.log("Executing FFMPEG: ", cmd)
    exec cmd, (error, stdout, stderr)->
      if (error)
        console.log('exec error: ' + error)
        return callback(error)
      console.log('ffmpeg stdout: ' + stdout)
      console.log('ffmpeg stderr: ' + stderr)
      callback()

  callMp4Box = (callback)->
    cmd = "#{MP4Box} -par 1=1:1 #{outputFile}"
    console.log("Executing MP4Box: ", cmd)
    exec cmd, (error, stdout, stderr)->
      if (error)
        console.log('exec error: ' + error)
        return callback(error)
      console.log('MP4Box stdout: ' + stdout)
      console.log('MP4Box stderr: ' + stderr)
      callback()

  async.series [ensureOutputEmpty, callFfmpeg, callMp4Box], callback
