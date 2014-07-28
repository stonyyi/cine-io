express = require("express")
fs = require("fs")
errorHandler = express.errorHandler()
API_PATH_REGEX = /\/api\/\d+\/-\// # /api/1/-/
_ = require('underscore')
raven = require('raven')
sentryClient = new raven.Client(Cine.config('variables/sentry').DSN)
AuthenticationError = require('passport/lib/errors/authenticationerror')

sendErr = (req, res, err, options={})->
  status = err.status || 400
  if err instanceof AuthenticationError
    response = req.session.messages.pop()
  else if options.api
    response = {message: err.message, status: status}
  else
    response = err
  res.send(status, response)

developmentHandler = (err, req, res, next) ->
  console.log('there is an err in development', err)
  return sendErr(req, res, err) if req.xhr
  return sendErr(req, res, err, api: true) if API_PATH_REGEX.test(req.originalUrl)
  errorHandler(err, req, res, next)

serveStaticErrorPage = (status, res)->
  errPage = "#{Cine.root}/public/error_pages/#{status}.html"
  fs.exists errPage, (exists)->
    res.status status
    if exists
      res.sendfile errPage
    else
      res.send 400, "An unknown error has occured."

logError = (err, req)->
  console.log("LOGGING ERROR")
  extra = _.extend({}, err.extra, req.headers, requestUrl: req.originalUrl)
  sentryClient.captureError(err, extra: extra)

productionHandler = (err, req, res, next) ->
  console.log('there is an err in production', err)
  logError(err, req)
  return sendErr(req, res, err) if req.xhr
  return sendErr(req, res, err, api: true) if API_PATH_REGEX.test(req.originalUrl)
  switch err.status
    when 401
      res.redirect("/401?originalUrl=#{req.originalUrl}")
    else
      serveStaticErrorPage(err.status, res)

module.exports = if process.env.NODE_ENV == 'development' then developmentHandler else productionHandler
