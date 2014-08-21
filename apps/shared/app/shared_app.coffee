BaseApp = require('rendr/shared/app')
window.Cine = require 'config/cine' if typeof window != 'undefined'
User = Cine.model('user')
Account = Cine.model('account')
handlebarsHelpers = Cine.lib('handlebars_helpers')
isServer = typeof window is 'undefined'
tracker = Cine.lib('tracker')

module.exports = class App extends BaseApp
  @flashKinds = ['success', 'warning', 'info', 'alert']
  @flashEvent = 'flash-message'
  initialize: ->
    BaseApp.prototype.initialize.call(this)
    @apiVersion = 1
    @templateAdapter.registerHelpers(handlebarsHelpers)
    if isServer
      @currentUser = new User(@req.currentUser, app: this)

  tracker: tracker

  start: ->
    @_setupRouterListeners()
    @_setupTracker()
    @_setupHerokuBoomerangBanner()
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

  # assume a single account for now
  # will be able to be set later on
  currentAccount: ->
    @_currentAccount ||= @currentUser.accounts().first()

  changeAccount: (account)->
    @_currentAccount = account
    @router.currentView.rerender()
    @_setupHerokuBoomerangBanner()

  _setupHerokuBoomerangBanner: ->
    return if typeof Boomerang is undefined
    return if !@currentUser.isLoggedIn()
    return @_removeBoomerang() if !@currentAccount().isHeroku()
    Boomerang.init({app: @currentAccount().get('herokuId'), addon: 'cine'})
    $('#heroku-boomerang').prependTo($('body'))

  _removeBoomerang: ->
    $('#heroku-boomerang').remove()

  _setupTracker: ->
    @tracker.load()
    @currentUser.on 'login', =>
      tracker.logIn(@currentUser)
    tracker.logIn(@currentUser) if @currentUser.isLoggedIn()
    @currentUser.on 'logout', =>
      delete @_currentAccount
      tracker.logOut()

  flash: (message, kind)->
    @trigger(@constructor.flashEvent, message: message, kind: kind)
