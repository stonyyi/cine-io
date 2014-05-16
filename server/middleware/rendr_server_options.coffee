DataAdapter = Cine.server_lib('data_adapter')

createServerOptions = (app)->
  serverOptions =
    defaultEngine: 'coffee'
    dataAdapter: new DataAdapter(app)
    errorHandler: Cine.middleware('error_handling')
    appData: createServerOptions.appData(app)

  serverOptions

createServerOptions.appData = (app)->
  env: app.settings.env

module.exports = createServerOptions
