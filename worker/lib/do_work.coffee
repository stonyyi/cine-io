debug = require('debug')('cine:do_work')
moment = require('moment')
_ = require('underscore')
async = require('async')

scheduledTasks =
  once_a_day_worker:
    [
      'billing/charge_all_accounts_if_on_the_first_of_the_month'
    ]
  once_an_hour_worker:
    [
      'reporting/broadcast/download_and_parse_edgecast_logs'
      'reporting/broadcast/download_and_parse_cloudfront_logs'
      'stats/calculate_and_save_usage_stats'
      'billing/update_or_throttle_accounts_who_cannot_pay_for_overages'
    ]
  once_every_10_minutes:
    [
      'analyze_kue_queue'
    ]

runServerLib = (libraryName, payload, callback)->
  debug("running #{libraryName} with", payload, "at", moment().format('MMMM Do YYYY, h:mm:ss a'))
  library = Cine.server_lib(libraryName)
  switch library.length
    when 1 then library(callback)
    when 2 then library(payload, callback)
    else callback("library takes too many arguments wrong")

currentEnvironment = (jobName, payload, done)->
  runServerLib jobName, payload, (err, response)->
    debug(response)
    done(err, response)

runScheduledJob = (jobName, payload, done)->
  debug("Running scheduled job", jobName)
  runner = (libName, callback)-> runServerLib(libName, payload, callback)
  # needs to be series because recordings_processor needs to move files, then reap them
  async.eachSeries scheduledTasks[jobName], runner, done

doWork = (jobName, payload, done)->
  return done('unacceptable job') unless _.include(scheduableTasks, jobName)
  environment = require('../../config/environment')
  Cine.config('connect_to_mongo')
  return runScheduledJob(jobName, payload, done) if _.chain(scheduledTasks).keys().contains(jobName).value()
  return currentEnvironment(jobName, payload, done) if jobName == 'current_environment'
  runServerLib(jobName, payload, done)

doWork.acceptableJobs = [
  'current_environment'
  'update_account_with_heroku_details'
]

otherJobNames = _.keys(scheduledTasks)

scheduableTasks = doWork.acceptableJobs.concat otherJobNames

module.exports = doWork
