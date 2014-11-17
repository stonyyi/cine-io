_ = require('underscore')
Base = Cine.model('base')
Accounts = Cine.collection('accounts')
module.exports = class User extends Base
  @id: 'User'
  url: '/user'

  isLoggedIn: ->
    @id?

  logout: ->
    delete @_accounts
    @clear()

  @include Cine.lib('date_value')

  createdAt: ->
    @_dateValue('createdAt')

  isNew: ->
    twoMinutesAgo = new Date
    twoMinutesAgo.setMinutes(twoMinutesAgo.getMinutes() - 2)
    @createdAt() > twoMinutesAgo

  accounts: ->
    return @_accounts if @_accounts
    accounts = @get('accounts')
    return new Accounts([], app: @app) unless accounts
    @_accounts = new Accounts(accounts, app: @app)
