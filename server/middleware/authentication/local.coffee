passport = require('passport')
LocalStrategy = require('passport-local').Strategy
User = Cine.server_model('user')
createNewToken = Cine.middleware('authentication/remember_me').createNewToken
ProjectCreate = Cine.api('projects/create')

assignNewPasswordAndAddAProjectAndSave = (user, cleartext_password, req, callback)->
  user.assignHashedPasswordAndSalt cleartext_password, (err)->
    return callback(err, false) if err
    ProjectCreate.addExampleProjectToUser user, (err, projectJSON, options)->
      # we still want to allow the user to be created even if there is no stream
      return callback(null, user) if err == 'Next stream not available, please try again later'
      callback(err, user)

createNewUser = (email, cleartext_password, req, callback)->
  user = new User(email: email)
  user.new = true
  assignNewPasswordAndAddAProjectAndSave(user, cleartext_password, req, callback)

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
