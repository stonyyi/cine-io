env     = require './config/environment'
express = require 'express'
http = require 'http'

app = exports.app = express()
exports.server = http.createServer(app)

app.set 'title', 'Streamosaurus'

SS.middleware 'middleware', app
SS.middleware 'routes', app

app.use SS.middleware('error_handling')