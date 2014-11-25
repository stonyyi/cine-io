exports.show = (params, callback)->
  params.id = "solutions/#{params.id}"
  spec =
    model: { model: 'StaticDocument', params: { id: params.id } }

  @app.fetch spec, (err, result)->
    callback(err, result)
