ajax = require('./ajax')
getScript = require('./get_script')
playerReady = false
waitingCalls = []
# streamId: streamData
cachedStreamData = {}
BASE_URL = "http://cine.io/api/1/-"
# BASE_URL = "http://localtest.me:8181/api/1/-"

# {"id":"53718cef450ff80200f81856",
# "instanceName":"cines",
# "eventName":"cine1",
# "streamName":"cine1",
# "streamKey":"bass35"}
playerIsReady = ->
  playerReady = true
  for call in waitingCalls
    call.call()
  waitingCalls.lenth = 0

ensureLoaded = (cb)->
  return cb() if playerReady
  waitingCalls.push cb

getStreamDetails = (streamId, callback)->
  return callback(cachedStreamData[streamId]) if cachedStreamData[streamId]
  ajax
    url: "#{BASE_URL}/stream?apiKey=#{CineIO.config.apiKey}&id=#{streamId}"
    dataType: 'jsonp'
    success: (data, response, xhr)->
      callback(data)
    error: (thing)->
      throw new Error("Could not fetch stream #{streamId}")

# this assumes JW player is loaded
play = (streamId, domNode, playOptions)->
  getStreamDetails streamId, (stream)->
    jwplayer.key = "TVKg0kVV92Nwd/vHp3yI+9aTDoPQrSyz6BH1Bg=="
    stream = stream
    console.log('streaming', stream)
    options =
      stretching: 'uniform'
      width: '100%'
      aspectratio: '16:9'
      primary: 'flash'
      autostart: true
      metaData: true
      file: "rtmp://fml.cine.io/20C45E/#{stream.instanceName}/#{stream.streamName}?adbe-live-event=#{stream.eventName}"
      rtmp:
        subscribe: true
    jwplayer(domNode).setup(options)

requiresInit = ->
  throw new Error("CineIO.init(API_KEY) has not been called.") unless CineIO.config.apiKey

CineIO =
  config: {}
  init: (apiKey)->
    throw new Error("API Key required") unless apiKey
    CineIO.config.apiKey = apiKey
    return if playerReady
    getScript '//jwpsrv.com/library/sq8RfmIXEeOtdhIxOQfUww.js', playerIsReady

  play: (streamId, domNode, playOptions)->
    requiresInit()
    throw new Error("Stream ID required") unless streamId
    throw new Error("DOM node required") unless domNode
    ensureLoaded ->
      play(streamId, domNode, playOptions)
  quickPlay: ->
    # CineIO.init('376ade44e1163b471dd4aa5ed9a84599')
    # CineIO.play "537e62c68492b7a9b4f20920", 'example'
    CineIO.play "53718cef450ff80200f81856", 'example'
window.CineIO = CineIO if typeof window isnt 'undefined'

module.exports = CineIO
