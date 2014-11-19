compression = require('compression')
morgan = require('morgan')
bodyParser = require('body-parser')
methodOverride = require('method-override')
cookieParser = require('cookie-parser')

module.exports = (app) ->

  # Use compression
  app.use compression(threshold: 512)

  # log requests
  app.use morgan((if app.settings.env is "development" then "dev" else "combined"))

  # # parse form data
  app.use(bodyParser.urlencoded(extended: false))
  app.use(bodyParser.json())

  # for fake DELETE and PUT requests
  app.use methodOverride()
