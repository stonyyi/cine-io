requiresInit = ->
  throw new Error("CineIO.init(CINE_IO_PUBLIC_KEY) has not been called.") unless CineIO.config.publicKey

CineIO =
  config: {}
  init: (publicKey, options)->
    throw new Error("Public Key required") unless publicKey
    CineIO.config.publicKey = publicKey
    for prop, value of options
      CineIO.config[prop] = value

  reset: ->
    CineIO.config = {}

  play: (streamId, domNode, playOptions={})->
    requiresInit()
    throw new Error("Stream ID required") unless streamId
    throw new Error("DOM node required") unless domNode
    playStream(streamId, domNode, playOptions)

  publish: (streamId, password, domNode, publishOptions={})->
    requiresInit()
    throw new Error("Stream ID required") unless streamId
    throw new Error("password required") unless password
    throw new Error("DOM node required") unless domNode
    publishStream.new(streamId, password, domNode, publishOptions)

  getStreamDetails: (streamId, callback)->
    getStreamDetails(streamId, callback)

window.CineIO = CineIO if typeof window isnt 'undefined'

module.exports = CineIO

playStream = require('./play_stream')
publishStream = require('./publish_stream')
getStreamDetails = require('./get_stream_details')

