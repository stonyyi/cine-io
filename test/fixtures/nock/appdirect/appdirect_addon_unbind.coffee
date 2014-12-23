verifyOauthSignature = Cine.server_lib('appdirect/verify_oauth_signature')

createResponse = (accountId)->
  response =
    type: "ADDON_UNBIND"
    marketplace:
      partner: "APPDIRECT"
      baseUrl: "https://www.appdirect.com"

    applicationUuid: null
    creator:
      uuid: "a959d462-a6b0-41e3-b0eb-c73c1d199fd3"
      openId: "https://www.appdirect.com/openid/id/a959d462-a6b0-41e3-b0eb-c73c1d199fd3"
      email: "thomas@cine.io"
      firstName: "Thomas"
      lastName: "Shafer"
      language: "en"
      address: null
      attributes: null

    payload:
      user: null
      company: null
      account:
        accountIdentifier: accountId
        status: "ACTIVE"

      addonInstance:
        id: "solo"

      addonBinding: null
      order: null
      notice: null
      configuration: {}

    returnUrl: null

module.exports = (accountId)->
  path = '/api/integration/v1/events/2fe3a1c6-f10b-411c-94f1-de2794ff5c66'
  baseUrl = "https://cloudfoundry.appdirect.com"
  ensureProperOutgoingSignature = (val)->
    verifyOauthSignature(val, "#{baseUrl}#{path}")
  nock("#{baseUrl}:443")
  .matchHeader('authorization', ensureProperOutgoingSignature)
  .get(path)
  .reply(200, createResponse(accountId), 'content-type': 'text/plain;charset=UTF-8')
