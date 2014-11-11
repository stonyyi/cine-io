_ = require('underscore')
async = require('async')

scheduledTasks =
  once_an_hour_worker:
    [
      'reporting/download_and_parse_edgecast_logs'
      'stats/calculate_and_save_usage_stats'
      'throttle_accounts_who_cannot_pay_for_overages'
    ]

runServerLib = (libraryName, payload, callback)->
  console.log("running #{libraryName} with", payload)
  library = Cine.server_lib(libraryName)
  switch library.length
    when 1 then library(callback)
    when 2 then library(payload, callback)
    else callback("library takes too many arguments wrong")

currentEnvironment = (jobName, payload, done)->
  runServerLib jobName, payload, (err, response)->
    console.log(response)
    done(err, response)

runScheduledJob = (jobName, payload, done)->
  console.log("Running scheduled job", jobName)
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
