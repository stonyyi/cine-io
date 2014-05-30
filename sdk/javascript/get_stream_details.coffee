BASE_URL = "https://www.cine.io/api/1/-"

cachedStreamData = {}

module.exports = (streamId, callback)->
  return callback(null, cachedStreamData[streamId]) if cachedStreamData[streamId]
  ajax
    url: "#{BASE_URL}/stream?publicKey=#{Main.config.publicKey}&id=#{streamId}"
    dataType: 'jsonp'
    success: (data, response, xhr)->
      cachedStreamData[streamId] = data
      callback(null, data)
    error: ->
      callback("Could not fetch stream #{streamId}")

Main = require('./main')
ajax = require('./ajax')
