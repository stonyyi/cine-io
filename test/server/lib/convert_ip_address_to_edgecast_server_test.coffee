convertIpAddressToEdgecastServer = Cine.server_lib('convert_ip_address_to_edgecast_server')

describe 'convertIpAddressToEdgecastServer', ->
  it 'converts a San Francisco IP to lax', ->
    sfIp = "204.14.156.177"
    edgecastServer = convertIpAddressToEdgecastServer sfIp
    expect(edgecastServer.code).to.equal('lax')
