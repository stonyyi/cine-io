console.log('loaded home app')
express = require('express')

Base = Cine.require('apps/base')
module.exports = app = Base.app('Cine.io')

Cine.config('connect_to_mongo')

Cine.middleware 'middleware', app
Cine.middleware('health_check', app)
Cine.middleware('deploy_info', app)

app.use Cine.require('apps/home/main', app).handle
app.use '/admin/kue', Cine.require('apps/home/kue')
app.use '/admin', Cine.require('apps/home/admin', app).handle
app.use '/embed', Cine.require('apps/home/embed')

# Serve static assets
app.use express.static "#{Cine.root}/public"
app.use express.static "#{Cine.root}/ignored" if app.settings.env is 'development'
