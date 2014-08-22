Base = Cine.model('base')
isServer = typeof window is 'undefined'
capitalize = Cine.lib('capitalize')

module.exports = class Account extends Base
  @id: 'Account'
  url: if isServer then "/account?masterKey=:masterKey" else "/account"
  idAttribute: 'masterKey'
  @plans: ['free', 'solo', 'basic', 'pro']

  isHeroku: ->
    !!@get('herokuId')

  @include Cine.lib('date_value')

  createdAt: ->
    @_dateValue('createdAt')

  firstPlan: ->
    @get('plans')[0]

  displayName: ->
    @get('name') || capitalize(@firstPlan())
