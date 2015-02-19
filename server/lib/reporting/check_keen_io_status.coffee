debug = require('debug')('cine:check_keen_io_status')
request = require('request')

module.exports = (callback)->
  debug('checking keen status')
  options =
    url: 'http://status.keen.io/?format=json'
    json: true
  request options, (err, response, body)->
    return callback(err) if err
    return callback(body || 'not 200') if response.statusCode != 200
    debug('got indicator', body.status.indicator)
    return callback("keen is experiencing issues") if body.status.indicator != 'none'
    callback()
