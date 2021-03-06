verifyOauthSignature = Cine.server_lib('appdirect/verify_oauth_signature')

createResponse = (accountId)->
  response =
    type: "SUBSCRIPTION_NOTICE"
    marketplace:
      partner: "CLOUDFOUNDRY"
      baseUrl: "https://cloudfoundry.appdirect.com"

    applicationUuid: null
    flag: "DEVELOPMENT"
    creator:
      uuid: "5524eea2-00df-4a81-a4a9-57223a1fc5e6"
      openId: "https://cloudfoundry.appdirect.com/openid/id/5524eea2-00df-4a81-a4a9-57223a1fc5e6"
      email: "thomas@cine.io"
      firstName: "Thomas"
      lastName: "Shafer"
      language: "en"
      address: null
      attributes: null

    payload:
      user: null
      company:
        uuid: "75b53335-a2fa-4337-9e32-3f7196df711d"
        name: "cine.io"
        email: null
        phoneNumber: "6507041188"
        website: "https://www.cine.io"
        country: "US"
      account:
        accountIdentifier: accountId
        status: "SUSPENDED"
      notice:
        type: "REACTIVATED"
        message: null

      addonInstance: null
      addonBinding: null
      order: null
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
