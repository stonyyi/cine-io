_ = require('underscore')
convertIpAddressToEdgecastServer = Cine.server_lib('convert_ip_address_to_edgecast_server')

nullCase = server: null, code: null, transcode: null

convert = (params)->
  ipAddress = params.ipAddress || params.remoteIpAddress
  return "ipAddress not available" unless ipAddress

  geo = convertIpAddressToEdgecastServer(ipAddress)
  return nullCase unless geo

  code = geo.code
  url = "rtmp://stream.#{code}.cine.io/20C45E/cines"
  transcoding = "rtmp://publish-#{geo.transcode}.cine.io/live"
  return server: url, code: code, transcode: transcoding


module.exports = (params, callback)->
  response = convert(params)
  return callback(response, nullCase, status: 400) unless _.has(response, 'code')

  callback(null, response)


module.exports.convert = convert
module.exports.default =
  code: 'lax'
  url: "rtmp://stream.lax.cine.io/20C45E/cines"
  transcode: "rtmp://publish-west.cine.io/live"
