process.env.NODE_ENV ||= 'development'
process.env.TZ = 'UTC' # https://groups.google.com/forum/#!topic/nodejs/s1gCV44KYrQ
cluster = require('cluster')
clc = require "cli-color"

if process.env.NODE_ENV == "production" && !process.env.NO_NEWRELIC
  try
    require 'newrelic'
  catch e
    console.log "could not load newrelic"

# I don't have a better way to do this:
# When I spawn up a server to hit externally,
# I don't have direct access to the process code,
# but I want to intercept external http requests.
# This will at least block all external http requests.
# Will need a better solution when I'm expecting responses.
if process.env.NODE_ENV == "test"
  nock = require('nock')
  nock.disableNetConnect()

startMaster = ->
  _ = require 'underscore'

  return startSpawn() if process.env.NO_SPAWN
  if process.env.NODE_ENV == "development"
    numberToSpawn = 1
  else
    # numberToSpawn = require('os').cpus().length
    # I tried 1,2,3,4 and two handled load best.
    # I think it's a combo of memory and cpu bottlenecks
    numberToSpawn = 1
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
    server.workerId = cluster.worker.id unless cluster.isMaster

    port = process.env.PORT or 8181
    console.log clc.yellow("[App]"), "Starting #{app.get('title')} in #{app.settings.env} on #{port} (worker #{server.workerId})"

    # start server and listen to socket.io
    server.listen port
    process.send('listening')

if cluster.isMaster
  startMaster()
else
  startSpawn()
