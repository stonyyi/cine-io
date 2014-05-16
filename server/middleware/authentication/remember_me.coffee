passport = require('passport')
RememberMeStrategy = require('passport-remember-me').Strategy
RememberMeToken = Cine.server_model('remember_me_token')
User = Cine.server_model('user')

# TokenModel
# _user: objectId
# token: string

# takes a token
# finds and returns a user
# deletes the token
consumeToken = (token, done) ->
  return done(null, false) unless token
  RememberMeToken.findOne token: token, (err, rmt)->
    return done(err) if err
    return done(null, false) unless rmt
    User.findOne _id: rmt._user, (err, user)->
      return done(err) if err
      return done(null, false) unless user
      rmt.remove()
      done null, user

# creates a new Token associated with a user
# returns the token string
createNewToken = (user, done) ->
  rmt = new RememberMeToken(_user: user._id)
  rmt.save (err)->
    return done(err) if err
    done null, rmt.token

module.exports = (app) ->
  passport.use new RememberMeStrategy(consumeToken, createNewToken)

module.exports.createNewToken = createNewToken
module.exports.createNewToken.oneYear = 365 * 24 * 60 * 60 * 1000 # milliseconds
