ServerNearest = Cine.api('server/nearest')
Nearest = testApi ServerNearest

describe 'Server#Nearest', ->

  it 'will return an error without an ip address', (done)->
    params = {}
    Nearest params, (err, response, options)->
      expect(err).to.equal("ipAddress not available")
      expect(response).to.deep.equal(server: null, transcode: null, host: null, app: null, rtmpCDNHost: null, rtmpCDNApp: null, rtcPublish: null)
      expect(options).to.deep.equal(status: 400)
      done()

  it 'will return the default without an ip address whith default true', (done)->
    params = {default: 'ok'}
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal
        server: "rtmp://publish-sfo1.cine.io/live"
        host: "stream.lax.cine.io"
        rtmpCDNHost: 'stream.lax.cine.io'
        app: '20C45E/cines'
        rtmpCDNApp: '20C45E/cines'
        transcode: "rtmp://publish-sfo1.cine.io:1936/live"
        rtcPublish: "https://rtc-publish-sfo1.cine.io/"
      expect(options).to.be.undefined
      done()

  it 'will return a null when unknown', (done)->
    params = remoteIpAddress: "127.0.0.1"
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal(server: null, transcode: null, host: null, app: null, rtmpCDNHost: null, rtmpCDNApp: null, rtcPublish: null)
      done()

  it 'will return a default when unknown but with default true', (done)->
    params = remoteIpAddress: "127.0.0.1", default: 'ok'
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal
        server: "rtmp://publish-sfo1.cine.io/live"
        host: "stream.lax.cine.io"
        rtmpCDNHost: 'stream.lax.cine.io'
        app: '20C45E/cines'
        rtmpCDNApp: '20C45E/cines'
        transcode: "rtmp://publish-sfo1.cine.io:1936/live"
        rtcPublish: "https://rtc-publish-sfo1.cine.io/"
      expect(options).to.be.undefined
      done()

  it 'will return a localized publish value for a client ip address', (done)->
    # 61.93.0.0 is hong kong
    params = remoteIpAddress: "61.93.0.0"
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal
        server: "rtmp://publish-lon1.cine.io/live"
        host: "stream.hhp.cine.io"
        rtmpCDNHost: 'stream.hhp.cine.io'
        app: '20C45E/cines'
        rtmpCDNApp: '20C45E/cines'
        transcode: "rtmp://publish-lon1.cine.io:1936/live"
        rtcPublish: "https://rtc-publish-sfo1.cine.io/"
      done()

  it 'will return a localized publish value for parameter ipAddress', (done)->
    # 81.169.145.154 is berlin, germany
    params = ipAddress: "81.169.145.154"
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal
        server: "rtmp://publish-lon1.cine.io/live"
        host: "stream.fra.cine.io"
        rtmpCDNHost: 'stream.fra.cine.io'
        app: '20C45E/cines'
        rtmpCDNApp: '20C45E/cines'
        transcode: "rtmp://publish-lon1.cine.io:1936/live"
        rtcPublish: "https://rtc-publish-sfo1.cine.io/"
      done()

  it 'will return a localized publish value for lax', (done)->
    # 24.18.84.223 is seattle, wa
    params = ipAddress: "24.18.84.223"
    Nearest params, (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal
        server: "rtmp://publish-sfo1.cine.io/live"
        host: "stream.lax.cine.io"
        rtmpCDNHost: 'stream.lax.cine.io'
        app: '20C45E/cines'
        rtmpCDNApp: '20C45E/cines'
        transcode: "rtmp://publish-sfo1.cine.io:1936/live"
        rtcPublish: "https://rtc-publish-sfo1.cine.io/"
      done()
