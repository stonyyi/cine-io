debug = require('debug')('cine:analyze_kue_queue')
async = require('async')
_ = require('underscore')
createQueue = Cine.server_lib('create_queue')
kue = require('kue')

getQueueResults = (queueName, state, callback)->
  from = 0
  to = 10
  order = 0
  kue.Job.rangeByType queueName, state, from, to, order, callback

tenMinutesAgo = ->
  d = new Date
  d.setMinutes(d.getMinutes() - 10)
  d

logError = (message)->
  debug("logging error!!!", message)

jobWaitingLongerThan10Minutes = (job)->
  maxAge = tenMinutesAgo()
  # debug("UPDATED AT", job.updated_at)
  updatedAt = new Date(Number(job.updated_at))
  maxAge > updatedAt


checkState = (queueName, state, callback)->
  getQueueResults queueName, state, (err, jobs)->
    return callback(err) if err
    debug("Checking", jobs.length, "jobs in", queueName)
    jobsRunningTooLong = _.any jobs, jobWaitingLongerThan10Minutes
    return callback("Jobs in #{state} state longer than 10 minutes") if jobsRunningTooLong
    callback()


checkQueue = (queueName, callback)->
  checkState queueName, 'active', (err)->
    return callback(err) if err
    checkState queueName, 'inactive', (err)->
      return callback(err) if err
      callback()

module.exports = (callback)->
  queue = createQueue()
  queue.inactiveCount (err, inactiveCount)->
    return callback(err) if err
    queue.activeCount (err, activeCount)->
      return callback(err) if err

      # shortcut, no queue running or queued, just end
      return callback(null, active: 0, inactive: 0) if inactiveCount == 0 && activeCount == 0

      queue.types (err, queueNames)->
        return callback(err) if err
        async.each queueNames, checkQueue, (err)->
          return callback(err) if err
          callback(null, active: activeCount, inactive: inactiveCount)
