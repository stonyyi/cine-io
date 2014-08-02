convertIpAddressToEdgecastServer = Cine.server_lib('convert_ip_address_to_edgecast_server')

nullCase = server: null, code: null
module.exports = (params, callback)->
  ipAddress = params.ipAddress || params.remoteIpAddress
  return callback("ipAddress not available", nullCase, status: 400) unless ipAddress

  geo = convertIpAddressToEdgecastServer(ipAddress)
  return callback null, nullCase unless geo

  code = geo.code
  url = "rtmp://stream.#{code}.cine.io/20C45E/cines"
  callback null, server: url, code: code
