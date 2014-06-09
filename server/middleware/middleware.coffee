connect_redis = require('connect-redis')
_ = require('underscore')
express = require 'express'

module.exports = (app) ->

  # Use compression
  app.use express.compress()

  # log requests
  app.use express.logger((if app.settings.env is "development" then "dev" else null))

  # populates req.cookies
  # cookie secret
  app.use express.cookieParser "R@gyX#va^hE8862+{h)<oCh]^8X[RziT=L7HcPw78Qv9KF74{D"

  # Sessions
  RedisStore = connect_redis(express)
  app.use express.session(
    store: new RedisStore(Cine.config('variables/redis'))
    secret: ',6Cp8k)B36(7n2jyT6;T6eG4q.[9YcR6rQ{,8R4b{NZ3E)kcki'
  )

  # # parse form data
  app.use(express.urlencoded())
  app.use(express.json())

  # for fake DELETE and PUT requests
  app.use express.methodOverride()

  # CSRF protection, populates req.csrfToken()
  # if app.settings.env isnt "test"
  #   app.use(express.csrf())

  #   app.use (req, res, next)->
  #     return next() if req.xhr
  #     req._myCSRF = req.csrfToken()
  #     next()

  # generic force https and www
  app.use Cine.middleware('force_https_and_www') if app.settings.env is "production"

  if app.settings.env is "staging"
    authCredentials = Cine.config('variables/basic_auth')
    app.use express.basicAuth(authCredentials.user, authCredentials.password)

  Cine.middleware('authentication', app)
  Cine.middleware('health_check', app)
  Cine.middleware('deploy_info', app)
