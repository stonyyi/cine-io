Cine = require('./cine')
path = require('path')

Cine.root = path.resolve()

Cine.require = (pathName, args...)->
  response = require path.join(Cine.root, pathName)
  response = response(args...) if args.length > 0
  response

Cine.server = (type, args...) ->
  Cine.require("/server/#{type}")(args...)

Cine.server_model = (type) ->
  Cine.require("/server/models/#{type}")

Cine.server_lib = (type) ->
  Cine.require("/server/lib/#{type}")

Cine.api = (type) ->
  Cine.require("/server/api/#{type}")

Cine.config = (type) ->
  Cine.require("/config/#{type}")

Cine.middleware = (type, args...) ->
  response = Cine.require("/server/middleware/#{type}")
  response = response(args...) if args.length > 0
  response

module.exports = Cine