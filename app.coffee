env     = require './config/environment'
express = require 'express'
http = require 'http'

app = exports.app = express()
exports.server = http.createServer(app)

app.set 'title', 'Cine.io'

Cine.middleware 'middleware', app

Cine.server 'api_routes', app

app.use Cine.require('apps/main', app)

app.use express.static "#{Cine.root}/public"

app.use Cine.middleware('error_handling')
