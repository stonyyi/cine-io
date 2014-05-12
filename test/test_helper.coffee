process.env.NODE_ENV ||= 'test'
process.env.TZ = 'UTC' # https://groups.google.com/forum/#!topic/nodejs/s1gCV44KYrQ
require '../config/environment'

chai = require("chai")
chai.config.includeStack = true
global.expect = chai.expect
global.sinon = require("sinon")
global.nock = require('nock')
nock.disableNetConnect()
nock.enableNetConnect('127.0.0.1')
# nock.recorder.rec()
mongoose = require('mongoose')

truncateAllTables = Cine.require('test/helpers/truncate_all_tables')

# usecase: beforeEach resetMongo
global.resetMongo = (done)->
  if mongoose.connection._readyState == 1
    truncateAllTables done
  mongoose.connection.on "open", (ref) ->
    truncateAllTables done
