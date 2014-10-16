doWork = Cine.require('worker/lib/do_work')
ironWorker = require('iron_worker')
_ = require 'underscore'
client = new ironWorker.Client Cine.config('variables/ironio')
WORKER_NAME = 'MainWorker'
noop = ->

mergePayloadWithEnvironment = (jobPayload)->
  redis = Cine.config('variables/redis')
  environmentPayload =
    # pass the env
    NODE_ENV: process.env.NODE_ENV

    # we need mongo to access the records
    MONGOHQ_URL: Cine.config('variables/mongo')

    # we send mail (for example donation charge errors, and fan reminder emails)
    MANDRILL_APIKEY: Cine.config('variables/mandrill').api_key

    # we make calls to the heroku vendor api
    HEROKU_USERNAME: Cine.config('variables/heroku').username
    HEROKU_PASSWORD: Cine.config('variables/heroku').password

    # we interact with edgecast
    EDGECAST_TOKEN: Cine.config('variables/edgecast').token
    EDGECAST_FTP_HOST: Cine.config('variables/edgecast').ftp.host
    EDGECAST_FTP_USER: Cine.config('variables/edgecast').ftp.user
    EDGECAST_FTP_PASSWORD: Cine.config('variables/edgecast').ftp.password

  environment: environmentPayload, jobPayload: jobPayload

scheduleJob = (jobName, jobPayload={}, options={}, callback=noop)->
  if _.isFunction options
    callback = options
    options = {}
  else if _.isFunction jobPayload
    callback = jobPayload
    jobPayload = {}
    options = {}

  throw new Error("#{jobName} is not a possible job") unless _.include(doWork.acceptableJobs, jobName)
  payload = mergePayloadWithEnvironment(jobPayload)
  payload.jobName = jobName
  client.tasksCreate WORKER_NAME, payload, options, callback

module.exports = scheduleJob
