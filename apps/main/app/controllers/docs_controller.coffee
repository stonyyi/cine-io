setTitleAndDescription = Cine.lib('set_title_and_description')

exports.show = (params, callback)->
  params.id ||= 'main'
  params.id = "docs/#{params.id}"
  spec =
    model: { model: 'StaticDocument', params: { id: params.id } }

  setTitleAndDescription @app

  @app.fetch spec, (err, result)->
    callback(err, result)
