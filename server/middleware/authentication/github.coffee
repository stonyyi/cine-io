passport = require('passport')
GitHubStrategy = require('passport-github').Strategy
githubConfig = Cine.config('variables/github')
User = Cine.server_model('user')
request = require('request')
mailer = Cine.server_lib('mailer')
strategyOptions =
  clientID: githubConfig.clientId,
  clientSecret: githubConfig.clientSecret,
  callbackURL: githubConfig.callbackURL
  passReqToCallback: true
ProjectCreate = Cine.api('projects/create')

updateUserData = (user, profile, accessToken, callback)->
  user.githubData = profile._json
  user.githubAccessToken = accessToken
  user.save callback

createNewUser = (profile, plan, accessToken, callback)->
  console.log('got github profile', profile)
  email = profile.emails[0] && profile.emails[0].value
  saveUser = ->
    user = new User
      plan: plan
      githubId: profile.id
      email: email
      name: profile.displayName
      githubData: profile._json
      githubAccessToken: accessToken
    console.log("creating github user", user)
    ProjectCreate.addExampleProjectToUser user, (err, projectJSON, options)->
      mailer.welcomeEmail(user)
      # we still want to allow the user to be created even if there is no stream
      return callback(null, user) if err == 'Next stream not available, please try again later'
      callback(err, user)

  return saveUser() if email
  console.log('no email')
  # we didn't get a public email, add a private one
  options =
    url: "https://api.github.com/user/emails?access_token=#{accessToken}"
    headers:
      'User-Agent': githubConfig.appName

  request options, (err, response)->
    return saveUser() if err
    console.log('got response', response.body)
    body = JSON.parse(response.body)
    email = body[0].email if body[0]
    saveUser()
# refresh token is nullzies
findGithubUser = (req, accessToken, refreshToken, profile, callback)->
  # console.log(accessToken, refreshToken, profile)
  User.findOne githubId: profile.id, (err, user)->
    return callback(err) if err
    return updateUserData(user, profile, accessToken, callback) if user
    state = if req.query.state then JSON.parse(req.query.state) else {}
    createNewUser(profile, state.plan, accessToken, callback)

githubStrategy = new GitHubStrategy strategyOptions, findGithubUser

success = (req, res)->
  res.redirect('/')

module.exports = (app)->
  passport.use(githubStrategy)

  app.get '/auth/github', (req, res)->
    plan = req.query.plan
    passport.authenticate('github', scope: "user:email", state: JSON.stringify(plan: plan))(req, res)

  authWithFailure = passport.authenticate('github', failureRedirect: '/')
  app.get '/auth/github/callback', authWithFailure, success
