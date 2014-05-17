BaseApp = require('rendr/shared/app')
window.Cine = require 'config/cine' if typeof window != 'undefined'
User = Cine.model('user')
isServer = typeof window is 'undefined'

module.exports = class App extends BaseApp

  initialize: ->
    BaseApp.prototype.initialize.call(this)
    @apiVersion = 1
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
