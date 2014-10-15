request = require('request')
herokuConfig = Cine.config('variables/heroku')

herokuUrl = (account)->
  "https://api.heroku.com/vendor/apps/#{account.herokuId}"

module.exports = (account, callback)->
  requestOptions =
    url: herokuUrl(account)
    json: true
    auth:
      user: herokuConfig.username
      password: herokuConfig.password

  request requestOptions, (err, res, body)->
    return callback(err) if err
    return callback("not 200", body) if res.statusCode != 200
    callback(null, body)
