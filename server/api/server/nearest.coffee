_ = require('underscore')
convertIpAddressToEdgecastServer = Cine.server_lib('convert_ip_address_to_edgecast_server')

nullCase =
  server: null
  code: null
  transcode: null
  app: null
  host: null
  rtmpCDN: null
  rtmpCDNHost: null
  rtmpCDNApp: null

convert = (params)->
  ipAddress = params.ipAddress || params.remoteIpAddress
  return "ipAddress not available" unless ipAddress

  geo = convertIpAddressToEdgecastServer(ipAddress)
  return nullCase unless geo

  code = geo.code
  rtmpCDNHost = "stream.#{code}.cine.io"
  app = module.exports.default.app
  rtmpCDN = "rtmp://#{rtmpCDNHost}/#{app}"
  transcoding = "rtmp://publish-#{geo.transcode}.cine.io/live"
  return server: rtmpCDN, code: code, transcode: transcoding, host: rtmpCDNHost, app: app, rtmpCDNApp: app, rtmpCDN: rtmpCDN, rtmpCDNHost: rtmpCDNHost


module.exports = (params, callback)->
  response = convert(params)
  unless response.code
    return callback(null, module.exports.default) if params.default
    errorResponse = nullCase
    response = null if _.has(response, 'code')
    return callback(response, errorResponse, status: 400)

  callback(null, response)


module.exports.convert = convert
module.exports.default =
  code: 'lax'
  host: "stream.lax.cine.io"
  app: "20C45E/cines"
  rtmpCDNApp: "20C45E/cines"
  transcode: "rtmp://publish-west.cine.io/live"
  rtmpCDNHost: "stream.lax.cine.io"

module.exports.default.server = "rtmp://#{module.exports.default.host}/#{module.exports.default.app}"
module.exports.default.rtmpCDN = "rtmp://#{module.exports.default.host}/#{module.exports.default.app}"
