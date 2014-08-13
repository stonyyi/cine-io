passport = require('passport')
OpenIDStrategy = require('passport-openid').Strategy
domain = Cine.config('variables/appdirect').openIdDomain
User = Cine.server_model('user')

strategyOptions =
  returnURL: "#{domain}/appdirect/login/callback"
  realm: "#{domain}/"
  identifierField: 'openid'
  profile: true

findUser = (fullOpenIdUrl, profile, done)->
  parts = fullOpenIdUrl.split('/')
  identifier = parts[parts.length - 1]
  query = appdirectUUID: identifier
  User.findOne query, (err, user)->
    console.log()
    done(err, user)

Strategy = new OpenIDStrategy strategyOptions, findUser

passport.use Strategy

module.exports = (app)->
  app.get '/appdirect/login', passport.authenticate('openid')
  app.get '/appdirect/login/callback', passport.authenticate('openid', successRedirect: '/', failureRedirect: '/login')
