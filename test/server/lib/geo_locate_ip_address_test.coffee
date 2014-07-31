geoLocatIpAddress = Cine.server_lib('geo_locate_ip_address')

describe 'geoLocatIpAddress', ->
  it 'can lookup SF', ->
    ip = "204.14.156.177"
    geo = geoLocatIpAddress(ip)
    expect(geo.country).to.equal('US')
    expect(geo.region).to.equal('CA')
    expect(geo.city).to.equal('San Francisco')
