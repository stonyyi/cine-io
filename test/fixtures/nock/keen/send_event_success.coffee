module.exports = (collection, data)->
  nock('https://api.keen.io:443')
  .post("/3.0/projects/548b844ac2266c05648b501e/events/#{collection}", data)
  .reply(201, ["1f8b0800908d8b5402ffab564a2e4a4d2c494d51b25228292a4dad0500bed6111111000000"], { server: 'nginx',
  date: 'Sat, 13 Dec 2014 00:51:28 GMT',
  'content-type': 'application/json',
  'content-length': '37',
  connection: 'close',
  'content-encoding': 'gzip',
  expires: 'Sat, 01 Jan 2000 01:01:01 GMT',
  vary: 'Accept-Encoding',
  pragma: 'no-cache',
  'cache-control': 'private, no-cache, no-cache=Set-Cookie, max-age=0, s-maxage=0',
  'access-control-allow-origin': '*',
  'access-control-allow-headers': 'origin, content-type, accept, authorization, user-agent' })
