passport = require('passport')
GitHubStrategy = require('passport-github').Strategy
github = Cine.config('variables/github')
User = Cine.server_model('user')

strategyOptions =
  clientID: github.clientId,
  clientSecret: github.clientSecret,
  callbackURL: github.callbackURL

updateUserData = (user, profile, accessToken, callback)->
  user.githubData = profile._json
  user.githubAccessToken = accessToken
  user.save callback

createNewUser = (profile, accessToken, callback)->
  console.log('got github profile', profile)
  email = profile.emails[0] && profile.emails[0].value
  user = new User
    githubId: profile.id
    email: email
    name: profile.displayName
    githubData: profile._json
    githubAccessToken: accessToken
  console.log("creating github user", user)
  user.save callback

# refresh token is nullzies
findGithubUser = (accessToken, refreshToken, profile, callback)->
  # console.log(accessToken, refreshToken, profile)
  User.findOne githubId: profile.id, (err, user)->
    return callback(err) if err
    return updateUserData(user, profile, accessToken, callback) if user
    createNewUser(profile, accessToken, callback)

githubStrategy = new GitHubStrategy strategyOptions, findGithubUser

success = (req, res)->
  res.redirect('/')

module.exports = (app)->
  passport.use(githubStrategy)

  app.get '/auth/github', passport.authenticate('github', scope: "user:email")

  authWithFailure = passport.authenticate('github', failureRedirect: '/login')
  app.get '/auth/github/callback', authWithFailure, success
