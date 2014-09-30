_ = require 'underscore'
_str = require 'underscore.string'
client = Cine.server_lib('redis_client')

redisKey = 'sitestats'
exports.statsNames = ['usage', 'signups']

get = (key, callback)->
  client.hget redisKey, key, (err, reply)->
    return callback(err) if err
    callback(null, JSON.parse(reply))

set = (key, stats, callback)->
  client.hset redisKey, key, JSON.stringify(stats), ->
    callback(arguments...)

_.each exports.statsNames, (key)->
  exports["get#{_str.capitalize(key)}"] = (callback)->
    get(key, callback)
  exports["set#{_str.capitalize(key)}"] = (stats, callback)->
    set(key, stats, callback)
