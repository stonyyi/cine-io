response = "[{\"email\":\"thomase@cine.io\",\"status\":\"sent\",\"_id\":\"7af3c15b69ab46cb8fa8ded3370418fa\",\"reject_reason\":null}]"
module.exports = (options={})->
  options.times ||= 1
  nock('https://mandrillapp.com:443')
    # don't care about the data here
    .post('/api/1.0/messages/send-template.json')
    .times(options.times)
    .reply(200, response)
