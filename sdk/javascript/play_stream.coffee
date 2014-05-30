playerReady = false
loadingPlayer = false
waitingPlayCalls = []

defaultOptions =
  stretching: 'uniform'
  width: '100%'
  aspectratio: '16:9'
  primary: 'flash'
  autostart: true
  metaData: true
  controls: true
  mute: false
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

userOrDefault = (userOptions, key)->
  if Object.prototype.hasOwnProperty.call(userOptions, key) then userOptions[key] else defaultOptions[key]

# this assumes JW player is loaded
play = (streamId, domNode, playOptions)->
  getStreamDetails streamId, (stream)->
    switchToNative = ->
      return if jwplayer().getRenderingMode() == "flash"
      videoOptions =
         width: userOrDefault(playOptions, 'width')
         height: '100%'
         autoplay: userOrDefault(playOptions, 'autostart')
         controls: userOrDefault(playOptions, 'controls')
         mute: userOrDefault(playOptions, 'mute')
         src: stream.play.hls
      videoElement = "<video src='#{videoOptions.src}' height='#{videoOptions.height}' #{'autoplay' if videoOptions.autoplay} #{'controls' if videoOptions.controls} #{'autoplay' if videoOptions.mute}>"
      document.getElementById(domNode).innerHTML = videoElement

    jwplayer.key = CineIO.config.jwPlayerKey
    stream = stream
    console.log('streaming', stream)
    rtmpUrl = stream.play.rtmp
    options =
      file: rtmpUrl
      stretching: userOrDefault(playOptions, 'stretching')
      width: userOrDefault(playOptions, 'width')
      aspectratio: userOrDefault(playOptions, 'aspectratio')
      primary: userOrDefault(playOptions, 'primary')
      autostart: userOrDefault(playOptions, 'autostart')
      metaData: userOrDefault(playOptions, 'metaData')
      mute: userOrDefault(playOptions, 'mute')
      rtmp: userOrDefault(playOptions, 'rtmp')
      controlbar: userOrDefault(playOptions, 'controls')
    console.log('playing', options)
    jwplayer(domNode).setup(options)
    if !userOrDefault(playOptions, 'controls')
      jwplayer().setControls(false)
    jwplayer().onReady switchToNative
    jwplayer().onSetupError switchToNative



module.exports = (streamId, domNode, playOptions)->
  ensurePlayerLoaded ->
    play(streamId, domNode, playOptions)

getScript = require('./get_script')
getStreamDetails = require('./get_stream_details')
