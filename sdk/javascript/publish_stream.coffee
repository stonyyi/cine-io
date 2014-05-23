publisherReady = false
swfLoaded = false
waitingPublishCalls = []
# streamId: streamData
noop = ->

PUBLISHER_NAME = 'Recorder'

loadPublisher = (domNode)->
  domNode = 'example'
  swfVersionStr = "11.4.0"
  xiSwfUrlStr = "playerProductInstall.swf"
  flashvars = {}
  params = {}
  attributes = {}
  params.allowscriptaccess = "sameDomain"
  params.allowfullscreen = "true"
  attributes.id = domNode
  attributes.name = "Recorder"
  attributes.align = "middle"
  swfobject.embedSWF "recorder.swf", domNode, "720", "405", swfVersionStr, xiSwfUrlStr, flashvars, params, attributes, (embedEvent) ->
    if embedEvent.success
      readyCall = ->
        embedEvent.ref.setOptions(jsLogFunction: "_jsLogFunction", jsStatusFunction: "_publisherStatus")
        publisherIsReady()
      # need to wait a bit until initialization finishes
      setTimeout readyCall, 1000
      _publisherStatus "Configure your stream, then press start."

publisherIsReady = ->
  console.log('publisher is ready!!!')
  publisherReady = true
  for call in waitingPublishCalls
    call.call()
  waitingPublishCalls.length = 0

enqueuePublisherCallback = (domNode, cb)->
  waitingPublishCalls.push ->
    getPublisher domNode, cb


findPublisherInDom = (domNode)->
  node = document.getElementById(domNode)
  return node if node && node.name == PUBLISHER_NAME
  return false

swfObjectCallbackToLoadPublisher = (domNode)->
  return ->
    swfLoaded = true
    loadPublisher(domNode)

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
getPublisher = (domNode, cb)->
  publisher = findPublisherInDom(domNode)
  return cb(publisher) if publisher
  if swfLoaded
    enqueuePublisherCallback domNode, cb
    return loadPublisher(domNode)
  enqueuePublisherCallback domNode, cb
  getScript '//ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js', swfObjectCallbackToLoadPublisher(domNode, cb)

class Publisher
  constructor: (@streamId, @password, @domNode, @publishOptions)->
    @_ensureLoaded()
  publish: ->
    console.log('loading publisher')
    @_ensureLoaded (publisher)->
      console.log('streamingggg!!', publisher)
  _ensureLoaded: (cb=noop)->
    getPublisher @domNode, cb

exports.new = (streamId, password, domNode, publishOptions)->
  new Publisher(streamId, password, domNode, publishOptions)

window._publisherStatus = (msg)->
  console.log('_publisherStatus', msg)

window._jsLogFunction = (msg)->
  console.log('_jsLogFunction', msg)

getScript = require('./get_script')
