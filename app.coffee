env     = require './config/environment'

switch process.env.RUN_AS
  when 'hls'
    app = Cine.require('apps/m3u8')
  when 'signaling'
    app = Cine.require('apps/signaling')
  else
    app = Cine.require('apps/home')

if app
  app.use Cine.middleware('error_handling')
  http = require 'http'
  exports.app = app
  exports.server = http.createServer(app)

switch process.env.RUN_AS
  when 'signaling'
    Cine.require('apps/signaling/start_primus', exports.server)
