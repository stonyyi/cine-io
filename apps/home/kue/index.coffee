console.log('loaded kue app')

express = require('express')
module.exports = app = express()
kue = require('kue')

app.use Cine.middleware('ensure_site_admin')

Cine.server_lib('create_queue')()

app.use kue.app
