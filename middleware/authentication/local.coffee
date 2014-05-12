passport = require('passport')
LocalStrategy = require('passport-local').Strategy
User = Cine.model('user')
createNewToken = Cine.middleware('authentication/remember_me').createNewToken

assignNewPasswordAndSave = (user, cleartext_password, req, callback)->
  user.assignHashedPasswordAndSalt cleartext_password, (err)->
    return callback(err, false) if err
    user.save (err)->
      return callback(err, false) if err
      callback(null, user)

createNewUser = (email, cleartext_password, req, callback)->
  timezoneName = req.body.timezoneName
  user = new User(email: email, timezoneName: timezoneName)
  user.new = true
  assignNewPasswordAndSave(user, cleartext_password, req, callback)

validatePasswordOfExistingUser = (user, cleartext_password, callback)->
  user.isCorrectPassword cleartext_password, (err)->
    return callback('Incorrect email/password.', false, message: 'Incorrect username/password.') if err
    callback(null, user)

issueRememberMeToken = (req, res, next)->
  createNewToken req.user, (err, token)->
    return next() if err
    res.cookie('remember_me', token, maxAge: createNewToken.oneYear, httpOnly: true)
    next()

strategyFunction = (req, email, cleartext_password, done)->
  User.findOne email: email, (err, user)->
    return done(err) if err
    return createNewUser(email, cleartext_password, req, done) unless user
    validatePasswordOfExistingUser(user, cleartext_password, done)

module.exports = (app) ->
  passport.use new LocalStrategy(passReqToCallback: true, strategyFunction)

  app.post '/login', passport.authenticate('local'), issueRememberMeToken, (req, res)->
    res.send(req.user.simpleCurrentUserJSON())

  Cine.middleware('authentication/local/update_password', app)
