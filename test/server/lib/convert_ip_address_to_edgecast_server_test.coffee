convertIpAddressToEdgecastServer = Cine.server_lib('convert_ip_address_to_edgecast_server')

describe 'convertIpAddressToEdgecastServer', ->
  it 'converts a San Francisco IP to lax', ->
    sfIp = "204.14.156.177"
    edgecastServer = convertIpAddressToEdgecastServer sfIp
    expect(edgecastServer.rtmpCDNCode).to.equal('lax')
    expect(edgecastServer.cineioEndpointCode).to.equal('sfo1')

  it 'converts a Berlin IP to fra', ->
    sfIp = "81.169.145.154"
    edgecastServer = convertIpAddressToEdgecastServer sfIp
    expect(edgecastServer.rtmpCDNCode).to.equal('fra')
    expect(edgecastServer.cineioEndpointCode).to.equal('lon1')

  it 'returns null for localhost', ->
    sfIp = "127.0.0.1"
    edgecastServer = convertIpAddressToEdgecastServer sfIp
    expect(edgecastServer).to.equal(null)
