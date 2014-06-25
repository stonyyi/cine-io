module.exports = ->
  nock('https://github.com:443')
    .post('/login/oauth/access_token', "grant_type=authorization_code&redirect_uri=&client_id=0970d704f4137ab1e8a1&client_secret=be03b40082e3068f63e1357cda8c9526ff367f57&code=f82d92e61bf7f1605066")
    .reply(200, "access_token=5b375ac2ddd691be9a8468877ea38ad3ba86f440&scope=user%3Aemail&token_type=bearer")
