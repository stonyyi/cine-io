process.env.NODE_ENV ||= 'development'
process.env.TZ = 'UTC' # https://groups.google.com/forum/#!topic/nodejs/s1gCV44KYrQ

# Set environment
env = process.env.NODE_ENV
module.exports = env

# add console.debug
noop = ->
if env in ['development', 'test']
  console.debug = console.log
else
  console.debug = noop

# add global SS requiring object
SS = require('./streamosaurus_server')
global.SS = SS

# init mongo
mongo_config = SS.config('variables/mongo')
mongoose = require('mongoose')
mongoose.connect mongo_config
mongoose.connection.on "open", (ref) ->
  console.log("Connected to mongo at #{mongo_config}")
