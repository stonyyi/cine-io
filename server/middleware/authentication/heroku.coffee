# mostly copied from kensa create
# https://devcenter.heroku.com/articles/building-a-heroku-add-on#3-generate-an-add-on-manifest
crypto = require("crypto")
resources = []
herokuConfig = Cine.config('variables/heroku')
findOrCreateResourcesFromHerokuAndEngineYard = Cine.server_lib('find_or_create_resources_from_heroku_and_engineyard')
qs = require('qs')
scheduleJob = Cine.server_lib('schedule_job')

basic_auth = (req, res, next) ->
  if req.headers.authorization and req.headers.authorization.search("Basic ") is 0
    passedAuth = new Buffer(req.headers.authorization.split(" ")[1], "base64").toString()
    expectedAuth = herokuConfig.username + ":" + herokuConfig.password
    return next() if passedAuth == expectedAuth

  console.log "Unable to authenticate user"
  console.log req.headers.authorization
  res.header "WWW-Authenticate", "Basic realm=\"Admin Area\""
  res.status(401).send "Authentication required"

sso_auth = (req, res, next) ->
  accountId = req.param("id")
  console.log accountId
  console.log req.params
  console.log req.body
  console.log('email', req.param('email'))
  console.log('nav-data', req.param('nav-data'))
  pre_token = accountId + ":" + herokuConfig.ssoSalt + ":" + req.param("timestamp")
  shasum = crypto.createHash("sha1")
  shasum.update pre_token
  token = shasum.digest("hex")

  return res.status(403).send("Token Mismatch") if req.param("token") isnt token

  time = (new Date().getTime() / 1000) - (2 * 60)
  return res.status(403).send("Timestamp Expired") if parseInt(req.param("timestamp")) < time

  res.cookie "heroku-nav-data", req.param("nav-data")
  findOrCreateResourcesFromHerokuAndEngineYard.findUser accountId, req.param('email'), req, (err, user)->
    return res.status(400).send(err) if err
    return res.status(404).send("Not Found") unless user

    req.login user, next

successSSO = (req, res) ->
  res.redirect "/?#{qs.stringify(accountId: req.param("id"))}"

module.exports = (app)->

  # User just added us on heroku
  app.post "/heroku/resources", basic_auth, (request, response) ->
    console.log "POSTING HEROKU RESOURCES", request.body
    herokuId = request.body.heroku_id
    plan = request.body.plan
    findOrCreateResourcesFromHerokuAndEngineYard.newHerokuAccount herokuId, plan, (err, account, project)->
      console.log('created heroku account', err, account, project)
      return response.status(400).send(err) if err
      return response.status(400).send('could not make account') unless account

      resource =
        id: account._id
        plan: account.plans[0]
        config:
          CINE_IO_PUBLIC_KEY: project.publicKey
          CINE_IO_SECRET_KEY: project.secretKey
      response.send resource

      scheduleJob 'update_account_with_heroku_details', {accountId: account._id}

  # User changed plan on heroku
  app.put "/heroku/resources/:id", basic_auth, (request, response) ->
    console.log request.body
    console.log request.params
    accountId = request.params.id
    plan = request.body.plan
    findOrCreateResourcesFromHerokuAndEngineYard.updatePlan accountId, plan, (err, project)->
      console.log('updated', err, project)
      return response.status(400).send(err) if err
      return response.status(404).send("Not found") unless project
      response.send "ok"

  # User removed us from heroku
  app["delete"] "/heroku/resources/:id", basic_auth, (request, response) ->
    console.log request.params
    accountId = request.params.id
    findOrCreateResourcesFromHerokuAndEngineYard.deleteAccount accountId, (err, project)->
      return response.status(400).send(err) if err
      return response.status(404).send("Not found") unless project
      response.send "ok"

  # ??? - maybe SSO login
  app.get "/heroku/resources/:id", sso_auth, successSSO

  # definitely sso login
  app.post "/heroku/sso", sso_auth, successSSO
