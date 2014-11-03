_ = require('underscore')
sign = require('oauth-sign').hmacsign
consumerSecret = Cine.config('variables/appdirect').oauthConsumerSecret

# input interator: ['abc=def', 'ghi=jkl', …]
# output {abc: 'def', ghi: 'jkl', …}
putIntoObj = (accum, part)->
  authParts = part.split('=')
  accum[authParts[0]] = authParts[1].substr(1,authParts[1].length-2)
  accum

extractOauthParams = (authorization)->
  # sometimes it starts with "OAuth "
  authorization = authorization.replace(/^(OAuth\s?)?(.+)$/, "$2")
  parts = authorization.split(/\s?,\s?/)
  _.inject parts, putIntoObj, {}

getOauthParams = (authObj)->
  _.pick(authObj, 'oauth_consumer_key', 'oauth_nonce', 'oauth_timestamp', 'oauth_signature_method', 'oauth_version')

generate = (oauthParams, reqUrl, reqParams={}, httpMethod="GET")->
  fullParamList = _.extend({}, reqParams, oauthParams)
  generated = sign(httpMethod, reqUrl, fullParamList, consumerSecret)

  encodeURIComponent(generated)

isValid = (authorization, reqUrl, reqParams={}, httpMethod="GET")->
  authObj = extractOauthParams(authorization)
  oauthParams = getOauthParams(authObj)
  generated = generate(oauthParams, reqUrl, reqParams, httpMethod)
  # console.log("ACTUAL", generated, "EXPECTED", authObj.oauth_signature)
  generated == authObj.oauth_signature


module.exports = isValid
