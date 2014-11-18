env     = require './config/environment'
Cine.config('connect_to_mongo')
express = require 'express'
http = require 'http'

app = exports.app = express()
exports.server = http.createServer(app)

# since we're running on heroku which uses nginx
# http://expressjs.com/guide.html#proxies
app.enable('trust proxy')

app.set 'title', 'Cine.io'

Cine.middleware 'middleware', app

Cine.server 'api_routes', app

app.use Cine.require('apps/main', app).handle
app.use '/admin/kue', Cine.require('apps/kue')
app.use '/admin', Cine.require('apps/admin', app).handle
app.use '/embed', Cine.require('apps/embed')
app.use '/hls', Cine.require('apps/m3u8')

# Serve static assets
app.use express.static "#{Cine.root}/public"
app.use express.static "#{Cine.root}/ignored" if app.settings.env is 'development'

app.use Cine.middleware('error_handling')
