exports.show = (params, callback) ->
  console.log("showing dashboard#show")
  spec =
    model: { model: 'Stats', params: { id: 'the-stats' } }
    collection: { collection: 'Accounts', params: { throttled: true } }
  console.log("fetching spec", spec)
  @app.fetch spec, (err, result)->
    callback(err, result)
