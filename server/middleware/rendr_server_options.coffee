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
  google_analytics: Cine.config('variables/google_analytics')
  mixpanel:
    tracking_id: Cine.config('variables/mixpanel').tracking_id

module.exports = createServerOptions
