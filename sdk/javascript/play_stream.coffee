playerReady = false
loadingPlayer = false
waitingPlayCalls = []
BASE_URL = "rtmp://fml.cine.io/20C45E"

defaultOptions =
  stretching: 'uniform'
  width: '100%'
  aspectratio: '16:9'
  primary: 'flash'
  autostart: true
  metaData: true
  rtmp:
    subscribe: true

playerIsReady = ->
  playerReady = true
  for call in waitingPlayCalls
    call.call()
  waitingPlayCalls.length = 0

enqueuePlayerCallback = (cb)->
  waitingPlayCalls.push cb

ensurePlayerLoaded = (cb)->
  return cb() if playerReady
  return enqueuePlayerCallback(cb) if loadingPlayer
  loadingPlayer = true
  getScript '//jwpsrv.com/library/sq8RfmIXEeOtdhIxOQfUww.js', playerIsReady
  enqueuePlayerCallback cb

# this assumes JW player is loaded
play = (streamId, domNode, playOptions)->
  getStreamDetails streamId, (stream)->
    jwplayer.key = "TVKg0kVV92Nwd/vHp3yI+9aTDoPQrSyz6BH1Bg=="
    stream = stream
    console.log('streaming', stream)
    rtmpUrl = "#{BASE_URL}/#{stream.instanceName}/#{stream.streamName}?adbe-live-event=#{stream.eventName}"
    options =
      file: rtmpUrl
      stretching: playOptions.stretching || defaultOptions.stretching
      width: playOptions.width || defaultOptions.width
      aspectratio: playOptions.aspectratio || defaultOptions.aspectratio
      primary: playOptions.primary || defaultOptions.primary
      autostart: playOptions.autostart || defaultOptions.autostart
      metaData: playOptions.metaData || defaultOptions.metaData
      rtmp: playOptions.rtmp || defaultOptions.rtmp

    jwplayer(domNode).setup(options)

module.exports = (streamId, domNode, playOptions)->
  ensurePlayerLoaded ->
    play(streamId, domNode, playOptions)

getScript = require('./get_script')
getStreamDetails = require('./get_stream_details')
