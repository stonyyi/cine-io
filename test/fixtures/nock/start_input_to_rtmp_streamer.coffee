module.exports = (body)->
  nock('http://input-to-rtmp-streamer')
    .post('/start', body)
    .reply(200)
