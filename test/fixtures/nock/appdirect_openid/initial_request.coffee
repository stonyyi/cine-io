initialResponse = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
  <xrds:XRDS xmlns:xrds=\"xri://$xrds\">
    <XRD xmlns=\"xri://$xrd*($v*2.0)\">
      <Service priority=\"0\">
        <Type>http://specs.openid.net/auth/2.0/signon</Type>
        <Type>http://openid.net/srv/ax/1.0</Type>
        <Type>http://openid.net/sreg/1.0</Type>
        <Type>http://openid.net/extensions/sreg/1.1</Type>
        <URI>https://www.appdirect.com/openid/op</URI>
      </Service>
    </XRD>
  </xrds:XRDS>
"

module.exports = ->
  nock('https://www.appdirect.com')
    .get('/openid/id/a959d462-a6b0-41e3-b0eb-c73c1d199fd3')
    .reply(200, initialResponse, 'content-type': 'application/xrds+xml;charset=UTF-8')
