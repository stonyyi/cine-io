module.exports = (body)->
  nock('http://input-to-rtmp-streamer')
    .post('/stop', body)
    .reply(200)
