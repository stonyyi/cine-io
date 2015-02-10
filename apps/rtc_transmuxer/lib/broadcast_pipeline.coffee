request = require('request')
async = require('async')
debug = require('debug')('cine:broadcast_pipeline')
INPUT_TO_RTMP_STREAMER_HOST = Cine.config('variables/rtc_transmuxer/input_to_rtmp_streamer_host')
noop = ->

module.exports = class BroadcastPipeline
  constructor: (@kurentoClient, @streamName, @streamKey)->
  create: (callback)=>
    debug("creating pipeline")

    @_createWebRtcEndpoint (err, @result)=>
      @webRtcEndpoint = @result.webRtcEndpoint
      @httpGetEndpoint = @result.httpGetEndpoint
      @ready = true
      @webRtcEndpoint.connect @httpGetEndpoint, callback

  processOffer: (offer, callback)=>
    return callback("Not initialized") unless @ready
    @webRtcEndpoint.processOffer offer, (error, sdpAnswer)=>
      @offered = true
      return callback(error) if error
      callback null, sdpAnswer

  start: (callback=noop)->
    return callback("not offered") unless @offered
    @httpGetEndpoint.getUrl (err, url)=>
      debug("GOT URL", err, url)
      @_startStreaming(url, callback)

  stop: (callback=noop)->
    @pipeline.release() if @pipeline
    @ready = false
    @offered = false
    @_stopChunkedRtmpStreamer(callback)

  _createWebRtcEndpoint: (callback)=>

    @kurentoClient.create "MediaPipeline", (err, @pipeline)=>
      debug('got pipeline')
      return callback(err) if err
      asynCalls =
        httpGetEndpoint: (cb)->
          options =
            terminateOnEOS: true
            mediaProfile: 'WEBM'
          pipeline.create "HttpGetEndpoint", options, cb
        webRtcEndpoint: (cb)->
          pipeline.create "WebRtcEndpoint", cb

      # pipeline.on 'release', ->
      #   debug("released")

      async.parallel asynCalls, callback

  _startStreaming: (url, callback)->
    url = url.replace('kurento-media-server', 'docker-local.cine.io') if process.env.REPLACE_WITH_LOCAL

    @_startChunkedRtmpStreamer(url, callback)

  _startChunkedRtmpStreamer: (input, callback)->
    options =
      url: "http://#{INPUT_TO_RTMP_STREAMER_HOST}/start"
      json: true
      body:
        streamName: @streamName
        streamKey: @streamKey
        input: input
    debug("starting chunked-rtmp-streamer", options)
    request.post options, (err, response, body)->
      return callback(err) if err
      return callback("not 200", body) if response.statusCode != 200
      callback()
      # do nothing

  _stopChunkedRtmpStreamer: (callback)->
    options =
      url: "http://#{INPUT_TO_RTMP_STREAMER_HOST}/stop"
      json: true
      body:
        streamName: @streamName
        streamKey: @streamKey
    debug("stopping chunked-rtmp-streamer", options)
    request.post options, (err, response, body)->
      return callback(err) if err
      return callback(response.statusCode, body) if response.statusCode != 200
      callback()
      # do nothing
