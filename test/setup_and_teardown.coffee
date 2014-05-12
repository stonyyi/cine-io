_ = require('underscore')

beforeEach resetMongo

afterEach (done)->
  nock.cleanAll()
  # I don't know if this will help anything but there might be something in the event loop
  # and this might tick it out. This might prevent the next test before call to happen before
  # the last test has finished if there is something in the event queue
  process.nextTick(done)
