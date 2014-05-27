BASE_URL = "https://www.cine.io/api/1/-"
# BASE_URL = "http://localtest.me:8181/api/1/-"

# {"id":"53718cef450ff80200f81856",
# "instanceName":"cines",
# "eventName":"cine1",
# "streamName":"cine1",
# "streamKey":"bass35"}

cachedStreamData = {}

module.exports = (streamId, callback)->
  return callback(cachedStreamData[streamId]) if cachedStreamData[streamId]
  ajax
    url: "#{BASE_URL}/stream?apiKey=#{Main.config.apiKey}&id=#{streamId}"
    dataType: 'jsonp'
    success: (data, response, xhr)->
      cachedStreamData[streamId] = data
      callback(data)
    error: (thing)->
      throw new Error("Could not fetch stream #{streamId}")

Main = require('./main')
ajax = require('./ajax')
