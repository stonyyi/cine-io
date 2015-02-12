env = require '../config/environment'
fs = require('fs')
os = require("os")

noop = ->

DEFAULT_PORT = 80

jobs = null
exports._recreateQueue = ->
  jobs = Cine.server_lib('create_queue')(force: jobs?)

getJobs = ->
  jobs || exports._recreateQueue()

exports.app = (title, options={})->
  app = require('express')()

  # since we're running on heroku which uses nginx
  # http://expressjs.com/guide.html#proxies
  app.enable('trust proxy')

  app.set 'title', title if title

  Cine.middleware 'middleware_base', app, options

exports.listen = (appOrHTTPServer)->
  port = process.env.PORT || DEFAULT_PORT
  console.log("listening on", port)
  appOrHTTPServer.listen(port)

# scheduleJob("process-video", {file: "some-file"})
exports.scheduleJob = (queue, details={}, callback=noop)->
  console.log("scheduling job in", queue, details)
  job = getJobs().create(queue, details)
  job.save callback


# processJobs "process-video", (job, done)->
# processJobs "process-video", concurrency: 20, (job, done)->
processJobs = (queue, options, callback)->
  if typeof options == 'function'
    callback = options
    options = {}
  console.log("processing jobs for", queue)
  if options.concurrency
    getJobs().process(queue, options.concurrency, callback)
  else
    getJobs().process(queue, callback)

# eventually we need a per-machine specific name
exports.getQueueName = (runContext)->
  "#{os.hostname()}-#{runContext}-incoming"

exports.processJobs = (runContext, callback)->
  queueName = exports.getQueueName(runContext)
  processJobs(queueName, callback)

exports.watch = (dir, cb)->
  console.log("watching directory", dir)
  fs.watch(dir,cb)
