setTitleAndDescription = Cine.lib('set_title_and_description')

exports.show = (params, callback)->
  console.log('showing Billing#show')
  setTitleAndDescription @app
  return callback(status: 401) unless @app.currentUser.isLoggedIn()
  callback()
