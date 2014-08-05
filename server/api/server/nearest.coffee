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
  unless response.code
    return callback(null, module.exports.default) if params.default == 'true'
    errorResponse = nullCase
    response = null if _.has(response, 'code')
    return callback(response, errorResponse, status: 400)

  callback(null, response)


module.exports.convert = convert
module.exports.default =
  code: 'lax'
  url: "rtmp://stream.lax.cine.io/20C45E/cines"
  transcode: "rtmp://publish-west.cine.io/live"
