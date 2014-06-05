express = require("express")
fs = require("fs")
errorHandler = express.errorHandler()
API_PATH_REGEX = /\/api\/\d+\/-\// # /api/1/-/

developmentHandler = (err, req, res, next) ->
  console.log('there is an err in development', err)
  return res.send(err.status || 400, err) if req.xhr
  return res.send(err.status || 400, err) if API_PATH_REGEX.test(req.originalUrl)
  errorHandler(err, req, res, next)

serveStaticErrorPage = (status, res)->
  errPage = "#{Cine.root}/public/error_pages/#{status}.html"
  fs.exists errPage, (exists)->
    res.status status
    if exists
      res.sendfile errPage
    else
      res.send 400, "An unknown error has occured."

productionHandler = (err, req, res, next) ->
  console.log('there is an err in production', err, req, res)
  return res.send(err.status || 400, err) if req.xhr
  return res.send(err.status || 400, err) if API_PATH_REGEX.test(req.originalUrl)
  switch err.status
    when 401
      res.redirect("/401?originalUrl=#{req.originalUrl}")
    else
      serveStaticErrorPage(err.status, res)

module.exports = if process.env.NODE_ENV == 'development' then developmentHandler else productionHandler
