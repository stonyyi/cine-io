BaseAppView = require("rendr/client/app_view")
# $body = $("body")
module.exports = class AppView extends BaseAppView
  postInitialize: ->
    console.debug('postInitialize AppView')
    @app.on "change:loading", ((app, loading) ->
      # $body.toggleClass "loading", loading
    ), this

    @app.on "change:title", ((app, title) ->
      document.title = title
    ), this

    @app.on "change:description", ((app, description) ->
      $('head meta[name="description"]').attr('content', description)
    ), this
