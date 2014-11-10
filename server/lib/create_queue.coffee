_ = require('underscore')
kue = require('kue')
redisClient = Cine.server_lib('redis_client')
jobs = null

module.exports = (options={})->
  _.defaults(options, force: false)
  return jobs if jobs && !options.force
  jobs = _createQueue()

_createQueue = ->
  jobs.shutdown() if jobs
  kue.createQueue
    prefix: 'kue'
    redis:
      createClientFactory: redisClient.clientFactory
