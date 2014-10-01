redis  = require('redis')

authClient = (client, redisConfig)->
  return unless redisConfig.pass
    client.auth redisConfig.pass, (err)->
      throw err if err

selectDb = (client, redisConfig)->
  return unless redisConfig.db
  client.select(redisConfig.db)

newRedisClient = ->
  redisConfig = Cine.config('variables/redis')
  client = redis.createClient(redisConfig.port, redisConfig.host)
  authClient(client, redisConfig)
  selectDb(client, redisConfig)
  client

module.exports = newRedisClient()
