env = require '../config/environment'

express = require 'express'
morgan = require('morgan')
bodyParser = require('body-parser')
redisClient = Cine.server_lib('redis_client')

kue = require('kue')
noop = ->

jobs = null
exports._createQueue = ->
  jobs.shutdown() if jobs
  jobs = kue.createQueue
    prefix: 'kue'
    redis:
      createClientFactory: redisClient.clientFactory

exports._createQueue()

exports.app = ->
  app = express()

  # log requests
  app.use morgan((if process.env.NODE_ENV is "development" then "dev" else "combined"))

  # # parse form data
  app.use(bodyParser.urlencoded(extended: false))
  app.use(bodyParser.json())
  return app

exports.listen = (app, defaultPort)->
  app.listen(process.env.PORT || defaultPort)


# scheduleJob("process-video", {file: "some-file"})
exports.scheduleJob = (queue, details={}, callback=noop)->
  job = jobs.create(queue, details)
  job.save callback


# processJobs "process-video", (job, done)->
# processJobs "process-video", concurrency: 20, (job, done)->
processJobs = (queue, options, callback)->
  if typeof options == 'function'
    callback = options
    options = {}
  if options.concurrency
    jobs.process(queue, options.concurrency, callback)
  else
    jobs.process(queue, callback)

# eventually we need a per-machine specific name
exports.getQueueName = (runContext)->
  machineName = "GLOBAL"
  "#{machineName}-#{runContext}-incoming"

exports.processJobs = (runContext, callback)->
  queueName = exports.getQueueName(runContext)
  processJobs(queueName, callback)
