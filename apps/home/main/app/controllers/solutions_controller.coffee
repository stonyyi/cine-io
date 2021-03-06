setTitleAndDescription = Cine.lib('set_title_and_description')

exports.titlesAndDescriptions =
  ios:
    title: "APIs and SDKs for RTMP and HLS (h.264 / AAC) live video-streaming as well as WebRTC-based audio- and video-conferencing for iOS using Objective-C and Swift: cine.io"
    description: "cine.io provides APIs and SDKs to add live video-conferencing and video-streaming capabilities to your iOS apps. Stream video from your iPhone or iPad via RTMP and HLS using h.264 and AAC codecs. Make and receive calls or join group video-conferences on any iOS device."
  android:
    title: "APIs and SDKs for RTMP and HLS (h.264 / AAC) live video-streaming as well as WebRTC-based audio- and video-conferencing for Android using Java: cine.io"
    description: "cine.io provides APIs and SDKs to add live video-conferencing and video-streaming capabilities to your Android apps. Stream video from any Android device with a camera via RTMP and HLS using h.264 and AAC codecs. Make and receive calls or join group video-conferences on any Android device."


exports.show = (params, callback)->
  docId = "solutions/#{params.id}"
  spec =
    model: { model: 'StaticDocument', params: { id: docId } }

  setTitleAndDescription @app, exports.titlesAndDescriptions[params.id]

  @app.fetch spec, (err, result)->
    callback(err, result)
