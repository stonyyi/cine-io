setTitleAndDescription = Cine.lib('set_title_and_description')

exports.show = (params, callback) ->
  console.debug('showing recover_password#show', params)
  spec =
    model: {model: 'PasswordChangeRequest', params: {identifier: params.identifier}}

  setTitleAndDescription @app

  @app.fetch spec, (err, result)->
    return callback(err, result) if err
    callback(err, result)
