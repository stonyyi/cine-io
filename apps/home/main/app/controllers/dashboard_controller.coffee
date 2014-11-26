setTitleAndDescription = Cine.lib('set_title_and_description')

exports.show = (params, callback)->
  console.log('showing Dashboard#show')
  setTitleAndDescription @app
  return callback(status: 401) unless @app.currentUser.isLoggedIn()
  callback()
