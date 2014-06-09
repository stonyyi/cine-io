Heroku = require('heroku').Heroku

module.exports = (app) ->
  app.get '/deployinfo', (req, res)->
    herokuClient = new Heroku key:"8442fe9b-f97e-44ad-9423-41d45bb46098"
    herokuClient.get_releases "cine-io", (err, result)->
      if err
        console.log err
        res.send({error: err})
        return
      shortSha = result[result.length-1].commit
      res.send({sha: shortSha})
