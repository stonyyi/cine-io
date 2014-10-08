response =
  id: "df292d7b4b3549698ab363777601647f"

module.exports = (transcodeBody)->
  nock('http://vod-translator')
    .post('/', transcodeBody)
    .reply(200, response)
