_ = require('underscore')
convertIpAddressToEdgecastServer = Cine.server_lib('convert_ip_address_to_edgecast_server')

nullCase =
  server: null
  transcode: null
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
  cineIOTranscodeEndpoint = "rtmp://publish-#{geo.cineioEndpointCode}.cine.io:1936/live"
  response =
    server: cineIOEndpoint
    transcode: cineIOTranscodeEndpoint
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
  transcode: "rtmp://publish-sfo1.cine.io:1936/live"
  rtmpCDNHost: "stream.lax.cine.io"

module.exports.default.server = "rtmp://publish-sfo1.cine.io/live"
