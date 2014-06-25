response = [
  {
    email: "thomas@givingstage.com",
    primary: false,
    verified: true
  },
  {
    email: "thomasjshafer@gmail.com",
    primary: true,
    verified: true
  }
]
module.exports = ->
  nock('https://api.github.com:443')
    .get('/user/emails?access_token=5b375ac2ddd691be9a8468877ea38ad3ba86f440')
    .reply(200, response)
