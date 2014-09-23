process.env.NODE_ENV ||= 'test'
process.env.TZ = 'UTC' # https://groups.google.com/forum/#!topic/nodejs/s1gCV44KYrQ
require '../config/environment'
ModelUtils = require('rendr/shared/modelUtils')
http = require('http')
express = require('express')
chai = require("chai")
chai.config.includeStack = true
global.expect = chai.expect
global.sinon = require("sinon")
global.nock = require('nock')
nock.disableNetConnect()
nock.enableNetConnect('127.0.0.1')
# nock.recorder.rec()

if process.env.CI
  sh = require 'execSync'
  sh.run 'grunt prepareProductionAssets'

jsdom = require('jsdom').jsdom
document = jsdom('<html><head><script></script></head><body></body></html>')
window = document.parentWindow
global.jQuery = require("jquery")(window)

App = Cine.require "apps/main/app/app"
rendrServerOptions = Cine.middleware('rendr_server_options')
appAttributes = rendrServerOptions.appData(settings: {env: process.env.NODE_ENV})

global.requireFixture = (name)->
  require "./fixtures/#{name}"

newReq = (currentUser)->
  req = new http.ServerResponse("")
  req.param = express.request.param
  req.currentUser = currentUser
  req

global.newApp = (currentUser=null)->
  modelUtils = new ModelUtils("#{Cine.root}/apps/shared/")
  a = new App(appAttributes, modelUtils: modelUtils, entryPath: "#{Cine.root}/apps/main/", req: newReq(currentUser))

global.testApi = Cine.require('test/helpers/test_api')

global.mainApp = newApp()
