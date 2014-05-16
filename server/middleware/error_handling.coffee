express = require("express")
fs = require("fs")
errorHandler = express.errorHandler()

developmentHandler = (err, req, res, next) ->
  console.log('there is an err', err)
  return res.send(err.status || 400, err) if req.xhr
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
  console.log('there is an err', err)
  return res.send(err.status || 400, err) if req.xhr
  switch err.status
    when 401
      res.redirect("/401?originalUrl=#{req.originalUrl}")
    else
      serveStaticErrorPage(err.status, res)

module.exports = if process.env.NODE_ENV == 'development' then developmentHandler else productionHandler
