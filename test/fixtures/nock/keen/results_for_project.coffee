response = ["1f8b08000c04d05402ffab562a4a2d2ecd2951b252b034313033ac05009fc7160811000000"]
qs = require('qs')

module.exports = (projectId, month)->
  firstSecondInMonth = new Date(month.getFullYear(), month.getMonth(), 1)
  lastSecondInMonth = new Date(month.getFullYear(), month.getMonth() + 1)
  lastSecondInMonth.setSeconds(-1)

  filters =
    [
      {
        property_name: "projectId"
        operator: "eq"
        property_value: projectId.toString()
      }
      {
        property_name: "action"
        operator: "eq"
        property_value: "userTalkedInRoom"
      }
    ]
  timeframe =
    start: firstSecondInMonth.toISOString()
    end: lastSecondInMonth.toISOString()

  params =
    event_collection: 'peer-minutes'
    filters: filters
    target_property: "talkTimeInMilliseconds"
    timeframe: timeframe
    timezone: 0

  nock('https://api.keen.io:443')
    .post('/3.0/projects/548b844ac2266c05648b501e/queries/sum', params)
    .reply(200, response, { server: 'nginx',
    date: 'Mon, 15 Dec 2014 23:55:38 GMT',
    'content-type': 'application/json',
    'transfer-encoding': 'chunked',
    connection: 'close',
    expires: 'Sat, 01 Jan 2000 01:01:01 GMT',
    vary: 'Accept-Encoding',
    pragma: 'no-cache',
    'cache-control': 'private, no-cache, no-cache=Set-Cookie, max-age=0, s-maxage=0',
    'access-control-allow-origin': '*',
    'access-control-allow-headers': 'origin, content-type, accept, authorization, user-agent',
    'content-encoding': 'gzip' })
