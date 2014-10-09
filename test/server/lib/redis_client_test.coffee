client = Cine.server_lib('redis_client')

describe 'client', ->
  it 'is a redis client', ->
    expect(client.connected).to.be.true
    expect(client.reply_parser.name).to.equal('hiredis')

  it 'can call redis commands', (done)->
    client.set "my-key", 'my value', (err, reply)->
      expect(err).to.be.null
      expect(reply).to.equal("OK")
      client.get "my-key", (err, result)->
        expect(err).to.be.null
        expect(result).to.equal('my value')
        done()

  describe 'clientFactory', ->
    it 'returns a new redis', ->
      newClient = client.clientFactory()
      expect(newClient.commands_sent).to.equal(0)
      newClient.quit()
