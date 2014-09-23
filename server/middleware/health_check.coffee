module.exports = (app) ->
  app.get '/health', (req, res)->
    res.status(200).send("OK")
