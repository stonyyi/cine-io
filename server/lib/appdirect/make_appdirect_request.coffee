_ = require('underscore')
oauthTokens = Cine.config('variables/appdirect')
request = require('request')

# callback: (err, statusCode, jsonResponse)
module.exports = (url, callback)->
  options =
    url: url
    method: "GET"
    oauth:
      consumer_key: oauthTokens.oauthConsumerKey
      consumer_secret: oauthTokens.oauthConsumerSecret
    headers:
      Accept: 'application/json'
  request options, (err, response)->
    return callback(err, response.statusCode) if err || response.statusCode != 200
    body = (if _.isString(response.body) then JSON.parse(response.body) else response.body)
    # console.log("GOT APPDIRECT RESPONSE", body)
    return callback(null, 200, body)
