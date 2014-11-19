connect_redis = require('connect-redis')
_ = require('underscore')
session = require('express-session')
cookieParser = require('cookie-parser')

module.exports = (app) ->

  # populates req.cookies
  # cookie secret
  app.use cookieParser "R@gyX#va^hE8862+{h)<oCh]^8X[RziT=L7HcPw78Qv9KF74{D"

  # Sessions
  RedisStore = connect_redis(session)
  app.use session(
    store: new RedisStore(Cine.config('variables/redis'))
    secret: ',6Cp8k)B36(7n2jyT6;T6eG4q.[9YcR6rQ{,8R4b{NZ3E)kcki'
    saveUninitialized: true
    resave: true
  )

  # generic force https and www
  app.use Cine.middleware('force_https_and_www') if app.settings.env is "production"

  if process.env.USE_BASIC_AUTH
    auth = require('basic-auth')
    authCredentials = Cine.config('variables/basic_auth')

    app.use (req, res, next)->
      user = auth(req)
      if (user == undefined || user['name'] != authCredentials.user || user['pass'] != authCredentials.password)
        res.setHeader('WWW-Authenticate', 'Basic realm="cineiorealm"')
        res.status(401).send('Unauthorized')
      else
        next()

  Cine.middleware('authentication', app)
  Cine.middleware('appdirect', app)
  Cine.middleware('health_check', app)
  Cine.middleware('deploy_info', app)
