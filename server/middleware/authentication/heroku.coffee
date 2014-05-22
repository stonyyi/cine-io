# mostly copied from kensa create
# https://devcenter.heroku.com/articles/building-a-heroku-add-on#3-generate-an-add-on-manifest
crypto = require("crypto")
resources = []
herokuConfig = Cine.config('variables/heroku')
findOrCreateResourcesFromHeroku = Cine.server_lib('find_or_create_resources_from_heroku')

get_resource = (id) ->
  id = parseInt(id)
  for i of resources
    return resources[i]  if resources[i].id is id
  return

destroy_resource = (id) ->
  id = parseInt(id)
  for i of resources
    delete resources[i]  if resources[i].id is id
  return

basic_auth = (req, res, next) ->
  if req.headers.authorization and req.headers.authorization.search("Basic ") is 0
    passedAuth = new Buffer(req.headers.authorization.split(" ")[1], "base64").toString()
    expectedAuth = herokuConfig.username + ":" + herokuConfig.password
    return next() if passedAuth == expectedAuth

  console.log "Unable to authenticate user"
  console.log req.headers.authorization
  res.header "WWW-Authenticate", "Basic realm=\"Admin Area\""
  res.send "Authentication required", 401

sso_auth = (req, res, next) ->
  if req.params.length is 0
    projectId = req.param("id")
  else
    projectId = req.params.id
  console.log("HELLOOOO")
  console.log projectId
  console.log req.params
  console.log req.body
  console.log('email', req.param('email'))
  console.log('nav-data', req.param('nav-data'))
  pre_token = projectId + ":" + herokuConfig.ssoSalt + ":" + req.param("timestamp")
  shasum = crypto.createHash("sha1")
  shasum.update pre_token
  token = shasum.digest("hex")

  return res.send "Token Mismatch", 403 if req.param("token") isnt token

  time = (new Date().getTime() / 1000) - (2 * 60)
  return res.send "Timestamp Expired", 403 if parseInt(req.param("timestamp")) < time

  res.cookie "heroku-nav-data", req.param("nav-data")
  findOrCreateResourcesFromHeroku.findProject projectId, (err, project)->
    return response.send err, 400 if err
    return response.send "Not found", 404 unless project
    findOrCreateResourcesFromHeroku.getProjectUser project, req.param("email"), (err, user)->
      req.login user, next

module.exports = (app)->

  # User just added us on heroku
  app.post "/heroku/resources", basic_auth, (request, response) ->
    console.log "POSTING HEROKU RESOURCES", request.body
    herokuId = request.body.heroku_id
    plan = request.body.plan
    findOrCreateResourcesFromHeroku.createProject herokuId, plan, (err, project)->
      return response.send err, 400 if err
      return response.send 'could not make project', 400 unless project

      console.log('created', err, project)
      resource =
        id: project._id
        plan: project.plan
        config:
          CINE_IO_API_KEY: project.apiKey
      response.send resource

  # User changed plan on heroku
  app.put "/heroku/resources/:id", basic_auth, (request, response) ->
    console.log request.body
    console.log request.params
    projectId = request.params.id
    plan = request.body.plan
    findOrCreateResourcesFromHeroku.updatePlan projectId, plan, (err, project)->
      console.log('updated', err, project)
      return response.send err, 400 if err
      return response.send "Not found", 404 unless project
      response.send "ok"

  # User removed us from heroku
  app["delete"] "/heroku/resources/:id", basic_auth, (request, response) ->
    console.log request.params
    projectId = request.params.id
    findOrCreateResourcesFromHeroku.deleteProject projectId, (err, project)->
      return response.send err, 400 if err
      return response.send "Not found", 404 unless project
      response.send "ok"

  # ??? - maybe SSO login
  app.get "/heroku/resources/:id", sso_auth, (request, response) ->
    response.redirect "/"

  # definitely sso login
  app.post "/heroku/sso", sso_auth, (request, response) ->
    response.redirect "/"
