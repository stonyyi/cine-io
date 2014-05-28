publisherReady = false
loadingSWF = false
loadedSWF = false
waitingPublishCalls = []
BASE_URL = 'rtmp://publish.west.cine.io/live'
PUBLISHER_NAME = 'Publisher'
noop = ->

defaultOptions =
  serverURL: null
  streamName: null
  streamKey: null
  audioCodec: 'NellyMoser'
  streamWidth: 720
  streamHeight: 404
  streamFPS: 15
  keyFrameInterval: null
  intervalSecs: 10 #not passed to publisher
  bandwidth: 1500
  videoQuality: 90

loadPublisher = (domNode, publishOptions)->
  swfVersionStr = "11.4.0"
  xiSwfUrlStr = "playerProductInstall.swf"
  flashvars = {}
  params = {}
  attributes = {}
  params.allowscriptaccess = "sameDomain"
  params.allowfullscreen = "true"
  params.wmode = 'transparent'
  attributes.id = domNode
  attributes.name = PUBLISHER_NAME
  attributes.align = "middle"
  domWidth = document.getElementById(domNode).offsetWidth
  streamWidth = publishOptions.streamWidth || defaultOptions.streamWidth
  streamHeight = publishOptions.streamHeight || defaultOptions.streamHeight
  height = domWidth / (streamWidth / streamHeight)
  swfobject.embedSWF "publisher.swf", domNode, "100%", height, swfVersionStr, xiSwfUrlStr, flashvars, params, attributes, (embedEvent) ->
    if embedEvent.success
      readyCall = ->
        embedEvent.ref.setOptions(jsLogFunction: "_jsLogFunction", jsEmitFunction: "_publisherEmit")
        publisherIsReady()
      # need to wait a bit until initialization finishes
      setTimeout readyCall, 1000

publisherIsReady = ->
  console.log('publisher is ready!!!')
  publisherReady = true
  for call in waitingPublishCalls
    call.call()
  waitingPublishCalls.length = 0

enqueuePublisherCallback = (domNode, publishOptions, cb)->
  waitingPublishCalls.push ->
    getPublisher domNode, publishOptions, cb

findPublisherInDom = (domNode)->
  node = document.getElementById(domNode)
  return node if node && node.name == PUBLISHER_NAME
  return false

swfObjectCallbackToLoadPublisher = (domNode, publishOptions)->
  return ->
    loadedSWF = true
    loadPublisher(domNode, publishOptions)

# cb(publisher)
# Workflow:
# Case: SWFObject not loaded
#   1. Fetch swf object
#   2. load publisher into domNode
#   3. Return publisher to callback
# Case: SWFObject is loaded but not in domNode
#   1. load publsiher into domNode
#   2. Return publisher to callback
# Case: SWFObject is loaded and publisher in domNode
#   1. Return publisher to callback
getPublisher = (domNode, publishOptions, cb)->
  publisher = findPublisherInDom(domNode)
  return cb(publisher) if publisher
  return enqueuePublisherCallback domNode, publishOptions, cb if loadedSWF
  return enqueuePublisherCallback domNode, publishOptions, cb if loadingSWF
  loadingSWF = true
  enqueuePublisherCallback domNode, publishOptions, cb
  getScript '//ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js', swfObjectCallbackToLoadPublisher(domNode, publishOptions, cb)

generateStreamName = (stream, password)->
  "#{stream.name}?#{password}&adbe-live-event=#{stream.name}"

class Publisher
  constructor: (@streamId, @password, @domNode, @publishOptions)->
    @_ensureLoaded()

  start: ->
    console.log('loading publisher')
    @_ensureLoaded (publisher)=>
      console.log('fetching stream', publisher)
      getStreamDetails @streamId, (stream)=>
        options = @_options(stream)
        console.log('streamingggg!!', options)
        publisher.setOptions options
        publisher.start()

  stop: ->
    @_ensureLoaded (publisher)=>
      publisher.stop()

  _options: (stream)->
    options =
      serverURL: BASE_URL
      streamName: generateStreamName(stream, @password)
      audioCodec: @publishOptions.audioCodec || defaultOptions.audioCodec
      streamWidth: @publishOptions.streamWidth || defaultOptions.streamWidth
      streamHeight: @publishOptions.streamHeight || defaultOptions.streamHeight
      streamFPS: @publishOptions.streamFPS || defaultOptions.streamFPS
      bandwidth: @publishOptions.bandwidth || defaultOptions.bandwidth * 1024 * 8
      videoQuality: @publishOptions.videoQuality || defaultOptions.videoQuality
    intervalSecs = @publishOptions.intervalSecs || defaultOptions.intervalSecs
    options.keyFrameInterval = options.streamFPS * intervalSecs
    options

  _ensureLoaded: (cb=noop)->
    getPublisher @domNode, @publishOptions, cb

exports.new = (streamId, password, domNode, publishOptions)->
  new Publisher(streamId, password, domNode, publishOptions)

window._publisherEmit = (eventName, stuff...)->
  switch(eventName)
    when "connect", "disconnect", "publish", "status", "error"
      console.log(stuff...)
    else
      console.log(stuff...)


window._jsLogFunction = (msg)->
  console.log('_jsLogFunction', msg)

getScript = require('./get_script')
getStreamDetails = require('./get_stream_details')
