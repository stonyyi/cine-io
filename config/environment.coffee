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

# add global Cine requiring object


# TEMP HACK TO GET THIS TO WORK INITIALLY
CineServer = require('./cine_server')
Cine = CineServer.require('apps/home/cine')
for key of CineServer
  Cine[key] = CineServer[key] if CineServer.hasOwnProperty(key)
#END HACK

global.Cine = Cine

# init mongo
module.exports.connectToMongo = ->
