convertIpAddressToEdgecastServer = Cine.server_lib('convert_ip_address_to_edgecast_server')

module.exports = (params, callback)->
  ipAddress = params.ipAddress || params.remoteIpAddress
  return callback("ipAddress not available", {server: null}, status: 400) unless ipAddress

  geo = convertIpAddressToEdgecastServer(ipAddress)
  return callback null, server: null unless geo

  url = "rtmp://stream.#{geo.code}.cine.io/20C45E/cines"
  callback null, server: url
