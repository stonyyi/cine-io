exports.withObject = (stream)->
  exports.withAttribute(stream.streamName)
exports.withAttribute = (streamName)->
  "hls:#{streamName}.m3u8"
