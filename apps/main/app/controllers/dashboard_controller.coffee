exports.show = (params, callback)->
  console.log('showing Dashboard#show')
  return callback(status: 401) unless @app.currentUser.isLoggedIn()
  callback()
