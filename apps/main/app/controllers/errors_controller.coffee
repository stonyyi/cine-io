setTitleAndDescription = Cine.lib('set_title_and_description')

exports.not_found = (params, callback) ->
  setTitleAndDescription @app
  callback()

exports.unauthorized = (params, callback) ->
  setTitleAndDescription @app
  callback()

exports.server_error = (params, callback) ->
  setTitleAndDescription @app
  callback()
