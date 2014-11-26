env     = require './config/environment'
http = require 'http'

if process.env.RUN_AS == 'hls'
  app = Cine.require('apps/m3u8')
else
  app = Cine.require('apps/home')

exports.app = app
exports.server = http.createServer(app)

app.use Cine.middleware('error_handling')
