exports.show = (params, callback)->
  console.log('showing UsageReports#show')
  return callback(status: 401) unless @app.currentUser.isLoggedIn()
  currentAccount = @app.currentAccount()
  return callback(status: 404) unless currentAccount

  spec =
    model: { model: 'UsageReport', params: { masterKey: currentAccount.get('masterKey') } }

  @app.fetch spec, (err, result)->
    callback(err, result)
