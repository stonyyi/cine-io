_ = require('underscore')
async = require('async')

onceADayJobs = [
  'reporting/download_and_parse_edgecast_logs'
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

runOnceADayWorker = (payload, done)->
  runner = (libName, callback)-> runServerLib(libName, payload, callback)
  async.each onceADayJobs, runner, done

doWork = (jobName, payload, done)->
  return done('unacceptable job') unless _.include(scheduableTasks, jobName)
  environment = require('../../config/environment')
  return runOnceADayWorker(payload, done) if jobName == 'once_a_day_worker'
  return currentEnvironment(jobName, payload, done) if jobName == 'current_environment'
  runServerLib(jobName, payload, done)

doWork.acceptableJobs = [
  'current_environment'
]

otherJobNames = [
  'once_a_day_worker'
]

scheduableTasks = doWork.acceptableJobs.concat otherJobNames

module.exports = doWork
