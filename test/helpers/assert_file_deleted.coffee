fs = require('fs')
async = require('async')

module.exports = (targetFile, done)->
  fileDeleted = false
  testFunction = -> fileDeleted
  checkFunction = (callback)->
    fs.exists targetFile, (exists)->
      fileDeleted = !exists
      callback()
  async.until testFunction, checkFunction, done
