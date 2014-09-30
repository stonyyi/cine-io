_ = require('underscore')
mongoose = require('mongoose')
truncateAllTables = Cine.require('test/helpers/truncate_all_tables')
redisClient = Cine.server_lib('redis_client')

resetMongo = (done)->
  if mongoose.connection._readyState == 1
    truncateAllTables done
  mongoose.connection.on "open", (ref) ->
    truncateAllTables done

beforeEach resetMongo

resetRedis = (done)->
  redisClient.flushdb done

beforeEach resetRedis

afterEach (done)->
  nock.cleanAll()
  # I don't know if this will help anything but there might be something in the event loop
  # and this might tick it out. This might prevent the next test before call to happen before
  # the last test has finished if there is something in the event queue
  process.nextTick(done)
