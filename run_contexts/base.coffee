env = require '../config/environment'
fs = require('fs')
os = require("os")
express = require 'express'
morgan = require('morgan')
bodyParser = require('body-parser')

noop = ->

jobs = null
exports._recreateQueue = ->
  jobs = Cine.server_lib('create_queue')(force: jobs?)

getJobs = ->
  jobs || exports._recreateQueue()

exports.app = ->
  app = express()

  # log requests
  app.use morgan((if process.env.NODE_ENV is "development" then "dev" else "combined"))

  # # parse form data
  app.use(bodyParser.urlencoded(extended: false))
  app.use(bodyParser.json())
  return app

exports.listen = (app, defaultPort)->
  port = process.env.PORT || defaultPort
  console.log("listening on", port)
  app.listen(port)

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

exports.processJobs = (runContext, options, callback)->
  queueName = exports.getQueueName(runContext)
  processJobs(queueName, options, callback)

exports.watch = (dir, cb)->
  console.log("watching directory", dir)
  fs.watch(dir,cb)
