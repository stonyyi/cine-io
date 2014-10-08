process.env.NODE_ENV ||= 'development'
process.env.TZ = 'UTC' # https://groups.google.com/forum/#!topic/nodejs/s1gCV44KYrQ
env = require '../config/environment'

express = require 'express'
morgan = require('morgan')
bodyParser = require('body-parser')

exports.app = ->
  app = express()

  # log requests
  app.use morgan((if process.env.NODE_ENV is "development" then "dev" else "combined"))

  # # parse form data
  app.use(bodyParser.urlencoded(extended: false))
  app.use(bodyParser.json())
  return app

exports.listen = (app, defaultPort)->
  app.listen(process.env.PORT || defaultPort)
