exports.show = (params, callback)->
  spec =
    model: {model: 'Project', params: {apiKey: params.apiKey}}

  @app.fetch spec, (err, results)->
    callback(err, results)
