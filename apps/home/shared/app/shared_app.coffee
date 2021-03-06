BaseApp = require('rendr/shared/app')
qs = require('qs')
isServer = typeof window is 'undefined'

User = Cine.model('user')
Account = Cine.model('account')
handlebarsHelpers = Cine.lib('handlebars_helpers')
tracker = Cine.lib('tracker')
parseUri = Cine.lib('parse_uri')

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

  getAppViewClass: ->
    Cine.arch('shared_app_view')

  # assume a single account for now
  # will be able to be set later on
  currentAccount: ->
    @_currentAccount ||= @_fetchFirstAccount()

  changeAccount: (account)->
    @_currentAccount = account
    @router.currentView.rerender()
    @_setupHerokuBoomerangBanner()

  flash: (message, kind)->
    @trigger(@constructor.flashEvent, message: message, kind: kind)

  _setupHerokuBoomerangBanner: ->
    return if typeof Boomerang is undefined
    @_removeBoomerang()
    return if !@currentUser.isLoggedIn()
    return if !@currentAccount()?
    return if !@currentAccount().isHeroku()
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

  _fetchFirstAccount: ->
    if isServer
      initialAccountId = @req.param('accountId')
    else
      initialAccountId = qs.parse(parseUri(window.location).query).accountId
    accounts = @currentUser.accounts()
    accounts.findWhere(id: initialAccountId) || accounts.first()
