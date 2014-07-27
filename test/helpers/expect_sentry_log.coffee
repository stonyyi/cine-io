async = require('async')

module.exports = ->
  beforeEach ->
    @sentryMock = requireFixture('nock/sentry_log_error')()

  afterEach (done)->
    errorLogged = false
    testFunction = -> errorLogged
    checkFunction = (callback)=>
      errorLogged = @sentryMock.isDone()
      setTimeout callback
    async.until testFunction, checkFunction, done
