ServerNearest = Cine.api('server/nearest')
Nearest = testApi ServerNearest

describe 'Server#Nearest', ->

  it 'will return an error without an ip address', (done)->
    params = {}
    Nearest params, (err, response, options)->
      expect(err).to.equal("ipAddress not available")
      expect(response).to.deep.equal(server: null, code: null, transcode: null, host: null, app: null)
      expect(options).to.deep.equal(status: 400)
      done()

  it 'will return the default without an ip address whith default true', (done)->
    params = {default: 'ok'}
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal
        code: 'lax'
        server: "rtmp://stream.lax.cine.io/20C45E/cines"
        host: "stream.lax.cine.io"
        host: 'stream.lax.cine.io'
        app: '20C45E/cines'
        transcode: "rtmp://publish-west.cine.io/live"
      expect(options).to.be.undefined
      done()

  it 'will return a null when unknown', (done)->
    params = remoteIpAddress: "127.0.0.1"
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal(server: null, code: null, transcode: null, host: null, app: null)
      done()

  it 'will return a default when unknown but with default true', (done)->
    params = remoteIpAddress: "127.0.0.1", default: 'ok'
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal
        code: 'lax'
        server: "rtmp://stream.lax.cine.io/20C45E/cines"
        host: "stream.lax.cine.io"
        app: '20C45E/cines'
        transcode: "rtmp://publish-west.cine.io/live"
      expect(options).to.be.undefined
      done()

  it 'will return a localized publish value for a client ip address', (done)->
    # 93.191.59.34 is russia
    params = remoteIpAddress: "93.191.59.34"
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal
        code: 'hhp'
        server: "rtmp://stream.hhp.cine.io/20C45E/cines"
        host: "stream.hhp.cine.io"
        app: '20C45E/cines'
        transcode: "rtmp://publish-ams.cine.io/live"
      done()

  it 'will return a localized publish value for parameter ipAddress', (done)->
    # 81.169.145.154 is berlin, germany
    params = ipAddress: "81.169.145.154"
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal
        code: 'fra'
        server: "rtmp://stream.fra.cine.io/20C45E/cines"
        host: "stream.fra.cine.io"
        app: '20C45E/cines'
        transcode: "rtmp://publish-ams.cine.io/live"
      done()

  it 'will return a localized publish value for lax', (done)->
    # 50.184.110.201 is berkeley, ca
    params = ipAddress: "50.184.110.201"
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal
        code: 'lax'
        server: "rtmp://stream.lax.cine.io/20C45E/cines"
        host: "stream.lax.cine.io"
        app: '20C45E/cines'
        transcode: "rtmp://publish-west.cine.io/live"
      done()
