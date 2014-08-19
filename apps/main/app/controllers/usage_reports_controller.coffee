exports.show = (params, callback)->
  console.log('showing UsageReports#show')
  return callback(status: 401) unless @app.currentUser.isLoggedIn()

  spec =
    model: { model: 'UsageReport', params: { masterKey: @app.currentAccount().get('masterKey') } }

  @app.fetch spec, (err, result)->
    callback(err, result)
