exports.show = (params, callback) ->
  console.debug('showing recover_password#show', params)
  spec =
    model: {model: 'PasswordChangeRequest', params: {identifier: params.identifier}}

  @app.fetch spec, (err, result)->
    return callback(err, result) if err
    callback(err, result)
