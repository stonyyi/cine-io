Base = Cine.model('base')
capitalize = Cine.lib('capitalize')

module.exports = class Account extends Base
  @id: 'Account'
  url: "/account?masterKey=:masterKey"
  idAttribute: 'masterKey'
  @plans: ['free', 'solo', 'basic', 'pro']

  isHeroku: ->
    @get('provider') == 'heroku'

  isAppdirect: ->
    @get('provider') == 'appdirect'

  @include Cine.lib('date_value')

  createdAt: ->
    @_dateValue('createdAt')

  firstPlan: ->
    @get('plans')[0]

  displayName: ->
    @get('name') || capitalize(@firstPlan())
