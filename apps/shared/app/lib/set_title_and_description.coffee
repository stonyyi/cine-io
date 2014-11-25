_ = require('underscore')
module.exports = (app, options={})->
  _.defaults options,
    title: "cine.io: live video with RTC, RTMP, and HLS; APIs and SDKs for iOS, Android, and the web."
    description: "Build powerful iOS and Android native or web-based video apps using our APIs and SDKs for RTC, RTMP, and HLS."
  app.set 'title', options.title
  app.set 'description', options.description
