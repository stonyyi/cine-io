client = Cine.server_lib('keen_client')

describe 'client', ->
  expectKeen = (keenClient)->
    expect(keenClient.config.projectId).to.equal("548b844ac2266c05648b501e")
    expect(keenClient.run).to.be.a('function')
    expect(keenClient.addEvent).to.be.a('function')
    expect(keenClient.config.host).to.equal('api.keen.io/3.0')

  it 'is a keen client', ->
    expectKeen(client)

  describe 'clientFactory', ->
    it 'returns a new Keen', ->
      newClient = client.clientFactory()
      expectKeen(newClient)
      expect(newClient).not.to.equal(client)
