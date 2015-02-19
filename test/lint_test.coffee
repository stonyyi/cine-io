debug = require('debug')('cine:test:lint_test')
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
    # shared
    "apps/home/shared/app/models"
    "apps/home/shared/app/collections"
    # main
    "apps/home/main/app/controllers"
    "apps/home/main/app/views"
    #admin
    "apps/home/admin/app/controllers"
    "apps/home/admin/app/views"
    # server
    "server/api"
    "server/models"
    "server/lib/appdirect"
    "server/lib/billing"
    "server/lib/stats"
    "server/lib/stream_recordings"
  ]
  _.each fullyTestedDirectories, (path)->
    it "tests every file in #{path}", (done)->
      assertThisDirectoryHasATestForEveryFile path, done

  notDoneYet = [
    # admin
    "apps/home/admin/app/components"
    # main
    "apps/home/main/app/components"
    # shared
    "apps/home/shared/app/lib"
    # server
    "server/lib"
    "server/middleware"
  ]
  _.each notDoneYet, (path)->
    it "tests every file in #{path}"

  itOnly = ["", "only"].join('.')
  fileHasItOnly = (filePath, callback)->
    fs.readFile filePath, (err, data)->
      return callback(err) if err
      callback data.toString().indexOf(itOnly) >= 0

  it "ensures there is no #{itOnly} in the test suite", (done)->
    findCoffeeFiles 'test', (err, files)->
      return done(err) if err
      async.filter files, fileHasItOnly, (filesWithItOnly)->
        if filesWithItOnly.length > 0
          debug("files with #{itOnly}", filesWithItOnly)
        expect(filesWithItOnly).to.have.length(0)
        done()
