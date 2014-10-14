Base = Cine.model('base')
capitalize = Cine.lib('capitalize')
ProvidersAndPlans  = Cine.require('config/providers_and_plans')
_ = require('underscore')

planIsFree = (plan)->
  ProvidersAndPlans['cine.io'].plans[plan].price == 0

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

  needsCreditCard: ->
    return false unless @get('provider') == 'cine.io'
    return false if _.all @get('plans'), planIsFree
    !@get('stripeCard')?

  createdAt: ->
    @_dateValue('createdAt')

  firstPlan: ->
    @get('plans')[0]

  displayName: ->
    @get('name') || capitalize(@firstPlan())
