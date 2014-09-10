User = Cine.server_model('user')
passport = require('passport')
fullCurrentUserJSON = Cine.server_lib('full_current_user_json')

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
        fullCurrentUserJSON user, (err, user)->
          req.currentUser = user
          next(err)
    else
      next()

  Cine.middleware('authentication/remember_me', app)
  Cine.middleware('authentication/local', app)
  Cine.middleware('authentication/github', app)
  Cine.middleware('authentication/heroku', app)
  Cine.middleware('authentication/engineyard', app)

  app.get '/logout', (req, res)->
    res.clearCookie('remember_me')
    req.logout()
    res.send(200)
