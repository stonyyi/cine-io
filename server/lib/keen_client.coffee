Keen = require('keen.io')
config = Cine.config('variables/keen')

newKeenClient = ->
  Keen.configure
    projectId: config.projectId
    writeKey: config.writeKey
    readKey: config.readKey
    masterKey: config.masterKey

module.exports = newKeenClient()
module.exports.clientFactory = newKeenClient
