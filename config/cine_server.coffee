Cine = {}
path = require('path')

Cine.root = path.resolve()

Cine.require = (pathName, args...)->
  response = require path.join(Cine.root, pathName)
  response = response(args...) if args.length > 0
  response

Cine.model = (type) ->
  Cine.require("/models/#{type}")

Cine.lib = (type) ->
  Cine.require("/lib/#{type}")

Cine.api = (type) ->
  Cine.require("/api/#{type}")

Cine.config = (type) ->
  Cine.require("/config/#{type}")

Cine.middleware = (type, args...) ->
  response = Cine.require("/middleware/#{type}")
  response = response(args...) if args.length > 0
  response

module.exports = Cine
