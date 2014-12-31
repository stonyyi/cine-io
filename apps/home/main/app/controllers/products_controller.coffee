setTitleAndDescription = Cine.lib('set_title_and_description')

exports.titlesAndDescriptions =
  broadcast:
    title: "APIs and SDKs for RTMP and HLS (h.264 / AAC) live video streaming."
    # description: "cine.io provides APIs and SDKs to add live video-streaming capabilities to your iOS apps. Stream video from your iPhone or iPad via RTMP and HLS using h.264 and AAC codecs."
  peer:
    title: "APIs and SDKs for WebRTC real time video and audio streaming"
    # description: "cine.io provides APIs and SDKs to add live video-streaming capabilities to your Android apps. Stream video from any Android device with a camera via RTMP and HLS using h.264 and AAC codecs."

exports.show = (params, callback)->
  setTitleAndDescription @app, exports.titlesAndDescriptions[params.id]
  callback(null, product: params.id)
