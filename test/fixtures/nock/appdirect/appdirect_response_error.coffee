verifyOauthSignature = Cine.server_lib('appdirect/verify_oauth_signature')

response =
  code: "Gone"
  message:"Event with token 2fe3a1c6-f10b-411c-94f1-de2794ff5c66 has already been consumed."

module.exports = ->
  path = '/api/integration/v1/events/2fe3a1c6-f10b-411c-94f1-de2794ff5c66'
  baseUrl = "https://cloudfoundry.appdirect.com"
  ensureProperOutgoingSignature = (val)->
    verifyOauthSignature(val, "#{baseUrl}#{path}")
  nock("#{baseUrl}:443")
  .matchHeader('authorization', ensureProperOutgoingSignature)
  .get(path)
  .reply(410, response, 'content-type': 'text/plain;charset=UTF-8')
