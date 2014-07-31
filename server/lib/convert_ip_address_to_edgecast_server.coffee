nearestEdgecastServer = Cine.server_lib('nearest_edgecast_server')
geoLocatIpAddress = Cine.server_lib('geo_locate_ip_address')

module.exports = (ip)->
  geo = geoLocatIpAddress(ip)
  return null unless geo
  nearestEdgecastServer(geo.ll[0], geo.ll[1])
