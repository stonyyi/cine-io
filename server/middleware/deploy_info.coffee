Heroku = require('heroku').Heroku
herokuConfig = Cine.config('variables/heroku')
module.exports = (app) ->
  app.get '/deployinfo', (req, res)->

    herokuClient = new Heroku key: herokuConfig.accessKey

    herokuClient.get_releases herokuConfig.app, (err, result)->
      if err
        console.log err
        res.send({error: err})
        return
      shortSha = result[result.length-1].commit
      res.send({sha: shortSha})
