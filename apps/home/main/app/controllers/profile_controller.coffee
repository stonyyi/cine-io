setTitleAndDescription = Cine.lib('set_title_and_description')

exports.edit = (params, callback) ->
  console.debug('showing profile#edit')

  setTitleAndDescription @app

  return callback(status: 401) unless @app.currentUser.isLoggedIn()

  callback()
