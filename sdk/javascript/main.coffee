requiresInit = ->
  throw new Error("CineIO.init(API_KEY) has not been called.") unless CineIO.config.apiKey

CineIO =
  config: {}
  init: (apiKey)->
    throw new Error("API Key required") unless apiKey
    CineIO.config.apiKey = apiKey

  play: (streamId, domNode, playOptions)->
    requiresInit()
    throw new Error("Stream ID required") unless streamId
    throw new Error("DOM node required") unless domNode
    playStream(streamId, domNode, playOptions)

  publish: (streamId, password, domNode, publishOptions)->
    requiresInit()
    throw new Error("Stream ID required") unless streamId
    throw new Error("password required") unless password
    throw new Error("DOM node required") unless domNode
    publishStream.new(streamId, password, domNode, publishOptions)

  quickPlay: ->
    CineIO.play "53718cef450ff80200f81856", 'example'
    # CineIO.publish "53718cef450ff80200f81856", 'bass35', 'example'

window.CineIO = CineIO if typeof window isnt 'undefined'

module.exports = CineIO

playStream = require('./play_stream')
publishStream = require('./publish_stream')

