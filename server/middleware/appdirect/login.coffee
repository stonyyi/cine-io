passport = require('passport')
OpenIDStrategy = require('passport-openid').Strategy
domain = Cine.config('variables/appdirect').openIdDomain
User = Cine.server_model('user')

strategyOptions =
  returnURL: "#{domain}/appdirect/login/callback"
  realm: "#{domain}/"
  identifierField: 'openid'
  profile: true
  stateless: true
  passReqToCallback: true

findUser = (req, fullOpenIdUrl, profile, callback)->
  parts = fullOpenIdUrl.split('/')
  identifier = parts[parts.length - 1]
  query = appdirectUUID: identifier
  User.findOne query, (err, user)->
    return callback(err) if err
    return callback() if !user?
    user.lastLoginIP = req.ip
    user.save (err, user)->
      callback(err, user)

Strategy = new OpenIDStrategy strategyOptions, findUser

passport.use Strategy

module.exports = (app)->
  app.get '/appdirect/login', passport.authenticate('openid')
  app.get '/appdirect/login/callback', passport.authenticate('openid', successRedirect: '/', failureRedirect: '/login')
