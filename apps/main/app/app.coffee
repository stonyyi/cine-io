BaseApp = require('rendr/shared/app')
window.Cine = require 'config/cine' if typeof window != 'undefined'
User = Cine.model('user')
handlebarsHelpers = Cine.lib('handlebars_helpers')
isServer = typeof window is 'undefined'

module.exports = class App extends BaseApp
  @flashKinds = ['success', 'warning', 'info', 'alert']
  @flashEvent = 'flash-message'
  initialize: ->
    BaseApp.prototype.initialize.call(this)
    @apiVersion = 1
    @templateAdapter.registerHelpers(handlebarsHelpers)
    if isServer
      @currentUser = new User(@req.currentUser, app: this)

  start: ->
    @_setupRouterListeners()
    BaseApp.prototype.start.call(this)

  _setupRouterListeners: ->

    @router.on "action:start", (->
      @set loading: true
    ), this

    @router.on "action:end", (->
      @set loading: false
      # since we're doing push state, the browser doesn't scroll to the top of the page
      # because it has a current scroll position
      $('body').scrollTo('#content', 200, easing: 'easeOutQuart')
    ), this

  flash: (message, kind)->
    @trigger(@constructor.flashEvent, message: message, kind: kind)
