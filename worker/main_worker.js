Debug = require('debug')
Debug.enable('cine:*')
debug = Debug('cine:main_worker')
require('coffee-script/register')
_ = require('underscore')
Cine = require('./config/cine_server')

parsePayload = Cine.require('worker/lib/payload_parser')
doWork = Cine.require('worker/lib/do_work')

function errorExit(err) {
  console.error(err)
  process.exit(1)
}

function jobDone(jobName) {
  return function (err) {
    debug("Ran job", jobName)
    if(err) {return errorExit(err)}
    process.exit(0)
  };
};

function doWorkWithParsedPayload (err, payload) {
  if(err) {return errorExit(err)}

  _.extend(process.env, payload.environment)
  debug('running jobName', payload.jobName)
  debug('process environment', process.env)
  debug('job payload', payload.jobPayload)

  doWork(payload.jobName, payload.jobPayload, jobDone(payload.jobName))
}

parsePayload(process.argv, doWorkWithParsedPayload)
