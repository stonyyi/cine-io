SS = {}
path = require('path')

SS.root = path.resolve()

SS.require = (pathName, args...)->
  response = require path.join(SS.root, pathName)
  response = response(args...) if args.length > 0
  response

SS.model = (type) ->
  SS.require("/models/#{type}")

SS.lib = (type) ->
  SS.require("/lib/#{type}")

SS.api = (type) ->
  SS.require("/api/#{type}")

SS.config = (type) ->
  SS.require("/config/#{type}")

SS.middleware = (type, args...) ->
  response = SS.require("/middleware/#{type}")
  response = response(args...) if args.length > 0
  response

module.exports = SS
