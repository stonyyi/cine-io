BaseClientRouter = require "rendr/client/router"

Router = module.exports = (options) ->
  BaseClientRouter.call this, options

###
Set up inheritance.
###
Router:: = Object.create(BaseClientRouter::)
Router::constructor = BaseClientRouter

Router::postInitialize = ->
  @on "action:start", @trackImpression, this

Router::trackImpression = ->
  ga('send', 'pageview', window.location.pathname) if window.ga
