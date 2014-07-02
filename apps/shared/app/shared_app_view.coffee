BaseAppView = require("rendr/client/app_view")
# $body = $("body")
module.exports = class AppView extends BaseAppView
  postInitialize: ->
    console.debug('postInitialize AppView')
    @app.on "change:loading", ((app, loading) ->
      # $body.toggleClass "loading", loading
    ), this
