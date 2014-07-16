require('coffee-script/register')
_ = require('underscore')
Cine = require('./config/cine')

parsePayload = Cine.require('worker/lib/payload_parser')
doWork = Cine.require('worker/lib/do_work')

function errorExit(err) {
  console.error(err)
  process.exit(1)
}

function jobDone(jobName) {
  return function (err) {
    console.log("Ran job", jobName)
    if(err) {return errorExit(err)}
    process.exit(0)
  };
};

function doWorkWithParsedPayload (err, payload) {
  if(err) {return errorExit(err)}

  _.extend(process.env, payload.environment)
  console.log('running jobName', payload.jobName)
  console.log('process environment', process.env)
  console.log('job payload', payload.jobPayload)

  doWork(payload.jobName, payload.jobPayload, jobDone(payload.jobName))
}

parsePayload(process.argv, doWorkWithParsedPayload)
