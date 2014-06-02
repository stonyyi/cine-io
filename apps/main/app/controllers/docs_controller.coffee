exports.show = (params, callback)->
  params.id ||= 'main'
  params.id = "docs/#{params.id}"
  spec =
    model: { model: 'StaticDocument', params: { id: params.id } }

  @app.fetch spec, (err, result)->
    callback(err, result)
