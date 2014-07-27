response =
  id: "df292d7b4b3549698ab363777601647f"

module.exports = ->
  nock('https://app.getsentry.com:443:443')
  .post('/api/store/')
  .reply(200, response)
