_ = require('underscore')
compression = require('compression')
morgan = require('morgan')
bodyParser = require('body-parser')
methodOverride = require('method-override')
cookieParser = require('cookie-parser')

module.exports = (app, options={}) ->
  _.defaults(options, log: true)
  # Use compression
  app.use compression(threshold: 512)

  # log requests
  if options.log
    app.use morgan((if app.settings.env is "development" then "dev" else "combined"))

  # # parse form data
  app.use(bodyParser.urlencoded(extended: false))
  app.use(bodyParser.json())

  # for fake DELETE and PUT requests
  app.use methodOverride()
