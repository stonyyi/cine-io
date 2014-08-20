exports.edit = (params, callback) ->
  console.debug('showing profile#edit')

  return callback(status: 401) unless @app.currentUser.isLoggedIn()

  callback()
