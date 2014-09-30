redis  = require('redis')

newRedisClient = ->
  redisConfig = Cine.config('variables/redis')
  client = redis.createClient(redisConfig.port, redisConfig.host)
  return client unless redisConfig.pass
  client.auth redisConfig.pass, (err)->
    throw err if err
  client

module.exports = newRedisClient()
