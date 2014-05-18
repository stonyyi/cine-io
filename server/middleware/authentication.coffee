User = Cine.server_model('user')
passport = require('passport')

module.exports = (app)->
  app.use passport.initialize()
  app.use passport.session()
  app.use(passport.authenticate('remember-me'))

  passport.serializeUser (user, done)->
    done(null, user.id)

  passport.deserializeUser (id, done)->
    done(null, id)

  # This populates the req.currentUser only on non xhr requetss
  app.use (req, res, next)->
    if req.user && !req.xhr
      User.findById req.user, (err, user)->
        return next() if err || !user
        req.currentUser = user.simpleCurrentUserJSON()
        next(err)
    else
      next()

  Cine.middleware('authentication/remember_me', app)
  Cine.middleware('authentication/local', app)

  app.get '/logout', (req, res)->
    res.clearCookie('remember_me')
    req.logout()
    res.send(200)