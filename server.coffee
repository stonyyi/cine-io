process.env.NODE_ENV ||= 'development'
process.env.TZ = 'UTC' # https://groups.google.com/forum/#!topic/nodejs/s1gCV44KYrQ
cluster = require('cluster')
clc = require "cli-color"

if process.env.NODE_ENV == "production"
  try
    require 'newrelic'
  catch e
    console.log "could not load newrelic"

startMaster = ->
  _ = require 'underscore'

  if process.env.NODE_ENV == "development"
    numberToSpawn = 1
  else
    # numberToSpawn = require('os').cpus().length
    # I tried 1,2,3,4 and two handled load best.
    # I think it's a combo of memory and cpu bottlenecks
    numberToSpawn = 2
    console.log('CPU count', numberToSpawn)

  _.times(numberToSpawn, cluster.fork)
  cluster.on 'exit', (worker)->
    console.log(clc.yellow("[App]"), "Worker #{worker.id} died")
    cluster.fork()

startSpawn = ->
  startTime = new Date

  # require the application
  application = require('./app')
  app = application.app
  if app
    server = application.server
    server.workerId = cluster.worker.id

    port = process.env.PORT or 8181
    console.log clc.yellow("[App]"), "Starting #{app.get('title')} in #{app.settings.env} on #{port} (worker #{server.workerId})"

    # start server and listen to socket.io
    server.listen port

if cluster.isMaster
  startMaster()
else
  startSpawn()
