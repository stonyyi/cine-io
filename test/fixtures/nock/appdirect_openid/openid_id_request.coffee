response = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<xrds:XRDS xmlns:xrds=\"xri://$xrds\">\r\n  <XRD xmlns=\"xri://$xrd*($v*2.0)\">\r\n    <Service priority=\"0\">\r\n      <Type>http://specs.openid.net/auth/2.0/signon</Type>\r\n      <Type>http://openid.net/srv/ax/1.0</Type>\r\n      <Type>http://openid.net/sreg/1.0</Type>\r\n      <Type>http://openid.net/extensions/sreg/1.1</Type>\r\n      <URI>https://www.appdirect.com/openid/op</URI>\r\n    </Service>\r\n  </XRD>\r\n</xrds:XRDS>\r\n"

module.exports = ->
  nock('https://www.appdirect.com')
    .get('/openid/id/a959d462-a6b0-41e3-b0eb-c73c1d199fd3')
    .reply 200, response,
      'content-type': 'application/xrds+xml;charset=UTF-8'
