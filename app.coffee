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
  exports.app = app
  if process.env.SSL
    https = require('https')
    fs = require('fs')
    options =
      key: fs.readFileSync(__dirname + '/key.pem')
      cert: fs.readFileSync(__dirname + '/cert.pem')
      requestCert: true
      rejectUnauthorized: false
      agent: false
    exports.server = https.createServer(options, app)
  else
    http = require('http')
    exports.server = http.createServer(app)

switch process.env.RUN_AS
  when 'signaling'
    Cine.require('apps/signaling/start_primus', exports.server)
