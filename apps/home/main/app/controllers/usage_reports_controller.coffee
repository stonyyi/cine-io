setTitleAndDescription = Cine.lib('set_title_and_description')

exports.show = (params, callback)->
  console.log('showing UsageReports#show')

  setTitleAndDescription @app

  return callback(status: 401) unless @app.currentUser.isLoggedIn()
  currentAccount = @app.currentAccount()
  return callback(status: 404) unless currentAccount

  spec =
    model:
      model: 'UsageReport'
      params:
        masterKey: currentAccount.get('masterKey')
        scope: 'account'
        report: ['peerMilliseconds', 'bandwidth', 'storage']

  @app.fetch spec, (err, result)->
    callback(err, result)
