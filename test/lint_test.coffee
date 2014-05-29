walkDirectory = Cine.require('test/helpers/walk_directory')
fs = require('fs')
_ = require('underscore')
async = require('async')

describe 'the test suite', ->
  findCoffeeFiles = (path, callback)->
    regex = new RegExp("\.coffee$")
    fullPath = "#{Cine.root}/#{path}"
    walkDirectory fullPath, (err, results)->
      return callback(err, results) if err
      expect(results).to.have.length.above(0)
      results = _.filter results, (file)->
        regex.test(file)
      callback(null, results)

  assertAllFilesPresent = (files, done)->
    async.reject files, fs.exists, (missingFiles)->
      console.error('missingFiles:', missingFiles) if missingFiles.length > 0
      expect(missingFiles).to.have.length(0)
      done()

  transformToTestFileNames = (path, appFiles)->
    _.map appFiles, (file)->
      file.replace("/#{path}", "/test/#{path}").replace('.coffee', '_test.coffee')

  assertThisDirectoryHasATestForEveryFile = (path, done)->
    findCoffeeFiles path, (err, results)->
      return done(err) if err
      testsFiles = transformToTestFileNames(path, results)
      assertAllFilesPresent(testsFiles, done)

  fullyTestedDirectories = [
    # main
    "apps/main/app/models"
    "apps/main/app/collections"
    # server
    "server/api"
  ]
  _.each fullyTestedDirectories, (path)->
    it "tests every file in #{path}", (done)->
      assertThisDirectoryHasATestForEveryFile path, done

  notDoneYet = [
    # main
    "apps/main/app/controllers"
    "apps/main/app/lib"
    "apps/main/app/views"
    # server
    "server/lib"
    "server/middleware"
    "server/models"
  ]
  _.each notDoneYet, (path)->
    it "tests every file in #{path}"
