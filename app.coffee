env     = require './config/environment'
express = require 'express'
http = require 'http'

app = exports.app = express()
exports.server = http.createServer(app)

app.set 'title', 'Streamosaurus'

SS.middleware 'middleware', app
SS.middleware 'api_routes', app

app.get "/", (req, res) ->
  res.sendfile "#{SS.root}/public/index.html"

app.use express.static "#{SS.root}/public"

app.use SS.middleware('error_handling')
