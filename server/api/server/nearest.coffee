_ = require('underscore')
convertIpAddressToEdgecastServer = Cine.server_lib('convert_ip_address_to_edgecast_server')

RTMP_TRANSMUCODE_PORT = 1936

nullCase =
  server: null
  transcode: null
  rtcPublish: null
  app: null
  host: null
  rtmpCDNHost: null
  rtmpCDNApp: null

convert = (params)->
  ipAddress = params.ipAddress || params.remoteIpAddress
  return "ipAddress not available" unless ipAddress

  geo = convertIpAddressToEdgecastServer(ipAddress)
  return nullCase unless geo

  rtmpCDNHost = "stream.#{geo.rtmpCDNCode}.cine.io"
  app = module.exports.default.app
  cineIOEndpoint = "rtmp://publish-#{geo.cineioEndpointCode}.cine.io/live"
  cineIOTranscodeEndpoint = "rtmp://publish-#{geo.cineioEndpointCode}.cine.io:#{RTMP_TRANSMUCODE_PORT}/live"
  cineIORTCTranscodeEndpoint = "https://rtc-publish-#{geo.cineioRtcEndpointCode}.cine.io/"
  response =
    server: cineIOEndpoint
    transcode: cineIOTranscodeEndpoint
    rtcPublish: cineIORTCTranscodeEndpoint
    host: rtmpCDNHost
    app: app
    rtmpCDNApp: app
    rtmpCDNHost: rtmpCDNHost
  return response


module.exports = (params, callback)->
  response = convert(params)
  # console.log("response", response)
  unless response.server
    return callback(null, module.exports.default) if params.default
    errorResponse = nullCase
    response = null if _.has(response, 'server')
    return callback(response, errorResponse, status: 400)

  callback(null, response)


module.exports.convert = convert
module.exports.default =
  host: "stream.lax.cine.io"
  app: "20C45E/cines"
  rtmpCDNApp: "20C45E/cines"
  transcode: "rtmp://publish-sfo1.cine.io:#{RTMP_TRANSMUCODE_PORT}/live"
  rtmpCDNHost: "stream.lax.cine.io"
  rtcPublish: "https://rtc-publish-sfo1.cine.io/"
module.exports.default.server = "rtmp://publish-sfo1.cine.io/live"
