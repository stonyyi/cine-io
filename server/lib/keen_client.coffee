Keen = require('keen-js')
config = Cine.config('variables/keen')

newKeenClient = ->
  new Keen
    projectId: config.projectId
    writeKey: config.writeKey
    readKey: config.readKey
    masterKey: config.masterKey

module.exports = newKeenClient()
module.exports.clientFactory = newKeenClient
