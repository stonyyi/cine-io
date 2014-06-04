exports.edit = (params, callback) ->
  console.debug('showing account#edit')

  return callback(status: 401) unless @app.currentUser.isLoggedIn()

  callback()
