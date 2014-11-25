setTitleAndDescription = Cine.lib('set_title_and_description')

exports.show = (params, callback)->
  params.id = "solutions/#{params.id}"
  spec =
    model: { model: 'StaticDocument', params: { id: params.id } }

  setTitleAndDescription @app,
    title: "solutions-title-#{params.id}"
    description: "solutions-description-#{params.id}"

  @app.fetch spec, (err, result)->
    callback(err, result)
