_ = require 'underscore'
_str = require 'underscore.string'
moment = require('moment')
client = Cine.server_lib('redis_client')

mainRedisKey = 'sitestats'
exports.statsNames = ['usage', 'signups']

get = (key, callback)->
  client.hget mainRedisKey, key, (err, reply)->
    return callback(err) if err
    callback(null, JSON.parse(reply))

set = (key, stats, callback)->
  client.hset mainRedisKey, key, JSON.stringify(stats), ->
    callback(arguments...)

exports.getAll = (callback)->
  client.hgetall mainRedisKey, (err, obj)->
    return callback(err) if err
    parseResult = (accum, value, key)->
      accum[key] = JSON.parse(value)
      accum
    parsedResult = _.inject obj, parseResult, {}
    callback null, parsedResult

# 2014-08
formatMonth = (month)->
  moment(month).format("YYYY-MM")

_.each exports.statsNames, (key)->
  exports["get#{_str.capitalize(key)}"] = (month, callback)->
    redisKey = "#{key}-#{formatMonth(month)}"
    get(redisKey, callback)
  exports["set#{_str.capitalize(key)}"] = (month, stats, callback)->
    redisKey = "#{key}-#{formatMonth(month)}"
    set(redisKey, stats, callback)
