passport = require('passport')
GitHubStrategy = require('passport-github').Strategy
request = require('request')
_ = require('underscore')
githubConfig = Cine.config('variables/github')
User = Cine.server_model('user')
mailer = Cine.server_lib('mailer')
strategyOptions =
  clientID: githubConfig.clientId,
  clientSecret: githubConfig.clientSecret,
  callbackURL: githubConfig.callbackURL
  passReqToCallback: true
ProjectCreate = Cine.api('projects/create')
createNewToken = Cine.middleware('authentication/remember_me').createNewToken
_str = require('underscore.string')
createNewAccount = Cine.server_lib('create_new_account')

updateUserData = (user, profile, accessToken, callback)->
  user.githubData = profile._json
  user.githubAccessToken = accessToken
  user.save callback

findBestGithubEmail = (githubEmails)->
  primaryEmail = _.find githubEmails, (githubEmail)->
    githubEmail.primary && githubEmail.verified
  return primaryEmail.email if primaryEmail
  firstVerifiedEmail = _.find githubEmails, (githubEmail)->
    githubEmail.verified
  return firstVerifiedEmail.email if firstVerifiedEmail
  firstEmail = body[0]
  return firstEmail.email if firstEmail
  null

createNewUser = (profile, plan, accessToken, callback)->
  console.log('got github profile', profile)
  email = profile.emails[0] && profile.emails[0].value
  console.log(profile)
  saveUser = ->
    accountAttributes =
      plan: plan
      billingProviderName: 'cine.io'
    userAttributes =
      githubId: profile.id
      email: email
      name: if _str.isBlank(profile.displayName) then profile.username else profile.displayName
      githubData: profile._json
      githubAccessToken: accessToken
    console.log("creating github user", userAttributes)
    createNewAccount accountAttributes, userAttributes, (err, results)->
      # console.log("CREATED GITHUB ACCOUNT", err, results)
      mailer.welcomeEmail(results.user)
      mailer.admin.newUser(results.user, 'github')
      callback(err, results.user)

  return saveUser() if email
  console.log('no email')
  # we didn't get a public email, fetch a private one
  options =
    url: "https://api.github.com/user/emails?access_token=#{accessToken}"
    headers:
      'User-Agent': githubConfig.appName

  request options, (err, response)->
    return saveUser() if err
    console.log('got response', response.body)
    body = JSON.parse(response.body)
    email = findBestGithubEmail(body)
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

issueRememberMeToken = (req, res, next)->
  createNewToken req.user, (err, token)->
    return next() if err
    res.cookie('remember_me', token, maxAge: createNewToken.oneYear, httpOnly: true)
    next()

success = (req, res)->
  state = JSON.parse(req.query.state)
  redirectUrl = switch state.client
    when 'web' then '/'
    when 'iOS' then "cineioconsole://login?masterKey=#{req.user.masterKey}&userToken=#{req.user.masterKey}"
  res.redirect(redirectUrl)

module.exports = (app)->
  passport.use(githubStrategy)

  app.get '/auth/github', (req, res)->
    state =
      plan: req.query.plan
      client: req.query.client
    passport.authenticate('github', scope: "user:email", state: JSON.stringify(state))(req, res)

  authWithFailure = passport.authenticate('github', failureRedirect: '/')
  app.get '/auth/github/callback', authWithFailure, issueRememberMeToken, success
