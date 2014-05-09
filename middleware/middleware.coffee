express = require 'express'
session = require('express-session')
cookieParser = require('cookie-parser')
compress = require('compression')
morgan  = require('morgan')
bodyParser = require('body-parser')
RedisStore = require('connect-redis')(session)
methodOverride = require('method-override')
csrf = require('csurf')

module.exports = (app) ->

  # Use compression
  app.use compress()

  # log requests
  if app.settings.env is "development"
    app.use morgan(format: "dev", immediate: true)
  else
    app.use morgan()

  # populates req.cookies
  # cookie secret
  app.use cookieParser "R@gyX#va^hE8862+{h)<oCh]^8X[RziT=L7HcPw78Qv9KF74{D"

  # Sessions
  app.use session(
    store: new RedisStore(SS.config('variables/redis')),
    secret: ',6Cp8k)B36(7n2jyT6;T6eG4q.[9YcR6rQ{,8R4b{NZ3E)kcki'
  )

  # # parse form data
  app.use(bodyParser())

  # for fake DELETE and PUT requests
  app.use methodOverride()

  # CSRF protection, populates req.csrfToken()
  if app.settings.env isnt "test"
    app.use csrf()

  SS.middleware('health_check', app)
