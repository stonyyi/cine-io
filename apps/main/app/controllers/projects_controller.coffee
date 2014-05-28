exports.show = (params, callback)->
  spec =
    model: {model: 'Project', params: {publicKey: params.publicKey}}

  @app.fetch spec, (err, results)->
    callback(err, results)
