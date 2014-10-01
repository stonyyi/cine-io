exports.show = (params, callback) ->
  console.log("showing dashboard#show")
  params.id ||= 'the-stats'
  spec =
    model: { model: 'Stats', params: { id: params.id } }
  console.log("fetching spec", spec)
  @app.fetch spec, (err, result)->
    callback(err, result)
