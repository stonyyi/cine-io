env     = require './config/environment'
express = require 'express'
http = require 'http'

app = exports.app = express()
exports.server = http.createServer(app)

app.set 'title', 'Streamosaurus'

Cine.middleware 'middleware', app
Cine.middleware 'api_routes', app

app.get "/", (req, res) ->
  res.sendfile "#{Cine.root}/public/index.html"

app.use express.static "#{Cine.root}/public"
app.use express.static "#{Cine.root}/bower_components"

app.use Cine.middleware('error_handling')
