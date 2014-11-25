setTitleAndDescription = Cine.lib('set_title_and_description')

exports.show = (params, callback)->
  params.id ||= 'terms-of-service'
  params.id = "legal/#{params.id}"
  spec =
    model: { model: 'StaticDocument', params: { id: params.id } }

  setTitleAndDescription @app

  @app.fetch spec, (err, result)->
    callback(err, result)
