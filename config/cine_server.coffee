Cine = require('./cine')
path = require('path')

Cine.root = path.resolve()

Cine.path = (pathName)->
  path.join(Cine.root, pathName)

Cine.require = (pathName, args...)->
  response = require Cine.path(pathName)
  response = response(args...) if args.length > 0
  response

Cine.server = (type, args...) ->
  response = Cine.require("/server/#{type}")
  response = response(args...) if args.length > 0
  response

Cine.server_model = (type) ->
  Cine.require("/server/models/#{type}")

Cine.server_lib = (type) ->
  Cine.require("/server/lib/#{type}")

Cine.api = (type) ->
  Cine.require("/server/api/#{type}")

Cine.run_context = (type) ->
  Cine.require("/run_contexts/#{type}")

Cine.config = (type) ->
  Cine.require("/config/#{type}")

Cine.middleware = (type, args...) ->
  response = Cine.require("/server/middleware/#{type}")
  response = response(args...) if args.length > 0
  response

module.exports = Cine
