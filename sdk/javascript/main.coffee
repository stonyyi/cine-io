requiresInit = ->
  throw new Error("CineIO.init(CINE_IO_PUBLIC_KEY) has not been called.") unless CineIO.config.publicKey

CineIO =
  config: {}
  init: (publicKey)->
    throw new Error("Public Key required") unless publicKey
    CineIO.config.publicKey = publicKey
  reset: ->
    delete CineIO.config.publicKey

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

  quickPlay: (playOptions={})->
    CineIO.play "53718cef450ff80200f81856", 'player-example', playOptions

  quickPublish: (publishOptions={})->
    publisher = CineIO.publish("53718cef450ff80200f81856", 'bass35', 'publisher-example', publishOptions)
    publisher.start()
    publisher

window.CineIO = CineIO if typeof window isnt 'undefined'

module.exports = CineIO

playStream = require('./play_stream')
publishStream = require('./publish_stream')

