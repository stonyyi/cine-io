currentEnvironment = Cine.server_lib('current_environment')

describe 'currentEnvironment', ->
  it 'returns the environment', (done)->
    currentEnvironment a: 'b', (err, response)->
      expect(err).to.be.null
      expect(response.payload).to.deep.equal(a: 'b')
      expect(response.NODE_ENV).to.deep.equal('test')
      expect(response.TZ).to.deep.equal('UTC')
      expect(response.currentTime).to.have.string("GMT+0000")
      expect(new Date response.currentTime).to.be.instanceOf(Date)
      done()
