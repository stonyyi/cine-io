passport = require('passport')
LocalStrategy = require('passport-local').Strategy
User = Cine.server_model('user')
createNewToken = Cine.middleware('authentication/remember_me').createNewToken
ProjectCreate = Cine.api('projects/create')
createNewAccount = Cine.server_lib('create_new_account')
fullCurrentUserJSON = Cine.server_lib('full_current_user_json')
mailer = Cine.server_lib('mailer')

createNewUser = (email, cleartextPassword, req, callback)->
  accountAttributes =
    productPlans:
      peer: req.body['peer-plan']
      broadcast: req.body['broadcast-plan'] || req.body.plan
    billingProvider: 'cine.io'
  userAttributes =
    email: email
    cleartextPassword: cleartextPassword
    lastLoginIP: req.ip
    createdAtIP: req.ip
  createNewAccount accountAttributes, userAttributes, (err, results)->
    return callback(err) if err
    mailer.admin.newUser(results.account, results.user, 'local')
    callback(null, results.user)

validatePasswordOfExistingUser = (user, cleartextPassword, req, callback)->
  user.isCorrectPassword cleartextPassword, (err)->
    return callback(null, false) if err
    user.lastLoginIP = req.ip
    user.save (err, user)->
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
    validatePasswordOfExistingUser(user, cleartextPassword, req, done)

module.exports = (app) ->
  passport.use new LocalStrategy(passReqToCallback: true, strategyFunction)

  app.post '/login', passport.authenticate('local', failWithError: true, failureMessage: 'Incorrect email/password.'), issueRememberMeToken, (req, res)->
    fullCurrentUserJSON req.user, (err, user)->
      res.send(user)

  Cine.middleware('authentication/local/update_password', app)
