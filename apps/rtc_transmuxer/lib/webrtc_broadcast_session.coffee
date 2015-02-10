BroadcastPipeline = Cine.app("rtc_transmuxer/lib/broadcast_pipeline")
getKurentoClient = Cine.app('rtc_transmuxer/lib/get_kurento_client')
EdgecastStream = Cine.server_model('edgecast_stream')
debug = require('debug')('webrtc_broadcast_session')

createPipeline = (stream, streamKey, callback) ->
  getKurentoClient (err, kurentoClient) ->
    return callback(err) if err
    debug("got kurentoClient")
    broadcastPipeline = new BroadcastPipeline(kurentoClient, stream.streamName, streamKey)
    callback(null, broadcastPipeline)

module.exports = class WebRTCBroadcastSession
  constructor: (@streamId, @streamKey)->
  handleOffer: (offer, callback)->
    @_createBroadcastPipeline (err)=>
      return callback(err) if err
      debug("created broadcastPipeline")
      @broadcastPipeline.processOffer offer, (err, sdpAnswer)=>
        @broadcastPipeline.start() if sdpAnswer
        callback(err, sdpAnswer)

  _createBroadcastPipeline: (callback)=>
    @_ensureStream (err)=>
      return callback(err) if err
      createPipeline @stream, @streamKey, (err, @broadcastPipeline)=>
        return callback(err) if err
        @broadcastPipeline.create (err)->
          return callback(err) if err
          callback()

  _ensureStream: (callback)=>
    return callback(null, @stream) if @stream
    EdgecastStream.findById @streamId, (err, @stream)=>
      return callback(err || 'not found') if err || !@stream
      return callback("incorrect password") if @stream.streamKey != @streamKey
      callback()

  stop: ->
    @broadcastPipeline?.stop()
