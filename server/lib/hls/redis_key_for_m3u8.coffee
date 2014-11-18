exports.withObjects = (project, stream)->
  exports.withAttributes(project.publicKey, stream.streamName)
exports.withAttributes = (publicKey, streamName)->
  "hls:#{publicKey}/#{streamName}.m3u8"
