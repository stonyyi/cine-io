passport = require('passport')
LocalStrategy = require('passport-local').Strategy
User = Cine.server_model('user')
createNewToken = Cine.middleware('authentication/remember_me').createNewToken
ProjectCreate = Cine.api('projects/create')
createNewAccount = Cine.server_lib('create_new_account')
fullCurrentUserJSON = Cine.server_lib('full_current_user_json')

createNewUser = (email, cleartextPassword, req, callback)->
  accountAttributes =
    plan: req.body.plan
    billingProvider: 'cine.io'
  userAttributes =
    email: email
    cleartextPassword: cleartextPassword
  createNewAccount accountAttributes, userAttributes, (err, results)->
    return callback(err) if err
    callback(null, results.user)

validatePasswordOfExistingUser = (user, cleartextPassword, callback)->
  user.isCorrectPassword cleartextPassword, (err)->
    return callback(null, false) if err
    callback(null, user)

issueRememberMeToken = (req, res, next)->
  createNewToken req.user, (err, token)->
    return next() if err
    res.cookie('remember_me', token, maxAge: createNewToken.oneYear, httpOnly: true)
    next()

strategyFunction = (req, email, cleartextPassword, done)->
  User.findOne email: email, (err, user)->
    return done(err) if err
    return createNewUser(email, cleartextPassword, req, done) unless user
    validatePasswordOfExistingUser(user, cleartextPassword, done)

module.exports = (app) ->
  passport.use new LocalStrategy(passReqToCallback: true, strategyFunction)

  app.post '/login', passport.authenticate('local', failWithError: true, failureMessage: 'Incorrect email/password.'), issueRememberMeToken, (req, res)->
    fullCurrentUserJSON req.user, (err, user)->
      res.send(user)

  Cine.middleware('authentication/local/update_password', app)
