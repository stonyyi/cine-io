exports.new = (params, callback)->
  return @redirectTo '/' if @app.currentUser.isLoggedIn()
  callback()
