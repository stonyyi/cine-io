# mostly copied from kensa create
# https://devcenter.heroku.com/articles/building-a-heroku-add-on#3-generate-an-add-on-manifest
crypto = require("crypto")
resources = []
herokuConfig = Cine.config('variables/heroku')

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
    if new Buffer(req.headers.authorization.split(" ")[1], "base64").toString() is herokuConfig.username + ":" + herokuConfig.password
      return next()
  console.log "Unable to authenticate user"
  console.log req.headers.authorization
  res.header "WWW-Authenticate", "Basic realm=\"Admin Area\""
  res.send "Authentication required", 401

sso_auth = (req, res, next) ->
  if req.params.length is 0
    id = req.param("id")
  else
    id = req.params.id
  console.log id
  console.log req.params
  pre_token = id + ":" + herokuConfig.ssoSalt + ":" + req.param("timestamp")
  shasum = crypto.createHash("sha1")
  shasum.update pre_token
  token = shasum.digest("hex")

  return res.send "Token Mismatch", 403 if req.param("token") isnt token

  time = (new Date().getTime() / 1000) - (2 * 60)
  return res.send "Timestamp Expired", 403 if parseInt(req.param("timestamp")) < time

  res.cookie "heroku-nav-data", req.param("nav-data")
  req.session.resource = get_resource(id)
  req.session.email = req.param("email")
  next()

module.exports = (app)->

  app.post "/heroku/resources", basic_auth, (request, response) ->
    console.log request.body
    resource =
      id: resources.length + 1
      plan: request.body.plan

    resource.config = CINE_IO_API_KEY: Math.random().toString()
    resources.push resource
    response.send resource

  app.put "/heroku/resources/:id", basic_auth, (request, response) ->
    console.log request.body
    console.log request.params
    resource = get_resource(request.params.id)
    return response.send "Not found", 404 unless resource
    resource.plan = request.body.plan
    response.send "ok"

  app["delete"] "/heroku/resources/:id", basic_auth, (request, response) ->
    console.log request.params
    return response.send "Not found", 404 unless get_resource(request.params.id)
    destroy_resource request.params.id
    response.send "ok"

  app.get "/heroku/resources/:id", sso_auth, (request, response) ->
    response.redirect "/"

  app.post "/heroku/sso", sso_auth, (request, response) ->
    response.redirect "/"
