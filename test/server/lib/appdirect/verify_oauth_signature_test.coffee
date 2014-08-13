verifyOauthSignature = Cine.server_lib('appdirect/verify_oauth_signature')

describe 'verifyOauthSignature', ->

  beforeEach ->
    @params =
      token: 'b3509a11-5ecd-4d4d-97ab-32e7d77408e5'
      url: 'https://cloudfoundry.appdirect.com/api/integration/v1/events/b3509a11-5ecd-4d4d-97ab-32e7d77408e5'
    @reqUrl = 'http://staging.cine.io/appdirect/create'
    @httpMethod = "GET"

  it 'returns true for a valid oauth signature', ->
    authorization = 'OAuth oauth_consumer_key="cineio-12056", oauth_nonce="1746785885757644257", oauth_signature="fdBQETGpsxHeYobQZ7YAoHFjW9Y%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1407971707", oauth_version="1.0"'
    expect(verifyOauthSignature(authorization, @reqUrl, @params, @httpMethod)).to.be.true

  it 'returns true for a valid oauth signature without OAuth prefix', ->
    authorization = 'oauth_consumer_key="cineio-12056", oauth_nonce="1746785885757644257", oauth_signature="fdBQETGpsxHeYobQZ7YAoHFjW9Y%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1407971707", oauth_version="1.0"'
    expect(verifyOauthSignature(authorization, @reqUrl, @params, @httpMethod)).to.be.true

  it 'returns false for an invalid oauth signature', ->
    authorization = 'OAuth oauth_consumer_key="cineio-12056", oauth_nonce="1746785885757644257", oauth_signature="gdBQETGpsxHeYobQZ7YAoHFjW9Y%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1407971707", oauth_version="1.0"'
    expect(verifyOauthSignature(authorization, @reqUrl, @params, @httpMethod)).to.be.false
