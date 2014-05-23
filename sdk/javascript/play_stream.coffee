playerReady = false
loadingPlayer = false
waitingPlayCalls = []

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

module.exports = (streamId, domNode, playOptions)->
  ensurePlayerLoaded ->
    play(streamId, domNode, playOptions)

getScript = require('./get_script')
getStreamDetails = require('./get_stream_details')
