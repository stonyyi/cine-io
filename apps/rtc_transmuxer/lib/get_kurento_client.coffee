KURENTO_HOST = Cine.config('variables/rtc_transmuxer/kurento_media_server_host')
kurentoWebsocketUri = "ws://#{KURENTO_HOST}/kurento"
kurento = require("kurento-client")
debug = require('debug')('cine:get_kurento_client')

kurentoClient = null
# Recover kurentoClient for the first time.
module.exports = (callback) ->
  return callback(null, kurentoClient) if kurentoClient isnt null
  debug("Connecting to kurento at", kurentoWebsocketUri)
  module.exports._getClient (err, _kurentoClient) ->
    if err
      debug "Coult not find media server at address " + kurentoWebsocketUri
      return callback("Could not find media server at address " + kurentoWebsocketUri + ". Exiting with err " + err)
    kurentoClient = _kurentoClient
    callback null, kurentoClient


module.exports._getClient = (callback)->
  kurento kurentoWebsocketUri, callback

module.exports._clear = ->
  kurentoClient = null
