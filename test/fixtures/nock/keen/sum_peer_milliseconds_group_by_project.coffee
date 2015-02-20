zlib = require('zlib')
# originalResult = [
#   "1f8b08000f03d95402ffab562a4a2d2ecd2951b25288ae562a28cacf4a4d2ef14c0172954c4d125312d3529212d3cc4c8d922d92932ccc8c4c2c8c0c957414109a8c2dcd2ccd8ccd2ccc6b636b019f8908314c000000"
# ]

getResponse = (response, done)->
  response = {"result": response}
  zlib.gzip JSON.stringify(response), (err, result)->
    done err, [result.toString('hex')]

# response must look like: [{"projectId": "54adafdbaf652c8cb8624821", "result": 396963687}]
module.exports = (expectedResponse, start, end, done)->

  getResponse expectedResponse, (err, response)->
    return done(err) if err
    params =
      event_collection: "peer-minutes"
      filters: [
        {
          property_name: "action"
          operator: "eq"
          property_value: "userTalkedInRoom"
        }
      ]
      group_by: "projectId"
      target_property: "talkTimeInMilliseconds"
      timeframe:
        start: start.toISOString()
        end: end.toISOString()
      timezone: 0

    responseHeaders =
      server: 'nginx',
      date: 'Mon, 09 Feb 2015 18:57:18 GMT',
      'content-type': 'application/json',
      'content-length': '86',
      connection: 'close',
      'content-encoding': 'gzip',
      expires: 'Sat, 01 Jan 2000 01:01:01 GMT',
      vary: 'Accept-Encoding',
      pragma: 'no-cache',
      'cache-control': 'private, no-cache, no-cache=Set-Cookie, max-age=0, s-maxage=0',
      'access-control-allow-origin': '*',
      'access-control-allow-headers': 'origin, content-type, accept, authorization, user-agent'

    thing = nock('https://api.keen.io:443')
    .post('/3.0/projects/548b844ac2266c05648b501e/queries/sum', params)
    .reply(200, response, responseHeaders)
    done(null, thing)
