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

  isDisabled: ->
    @get('isDisabled')

  needsCreditCard: ->
    return false unless @get('provider') == 'cine.io'
    return false if @get('cannotBeDisabled')
    return false if _.all @get('plans'), planIsFree
    !@get('stripeCard')?

  updateAccountUrl: ->
    return @get('appdirect').baseUrl if @get('provider') == 'appdirect'
    returnUrl =
      heroku: ProvidersAndPlans['heroku'].url
      engineyard: ProvidersAndPlans['engineyard'].url
      'cine.io': "https://www.cine.io/account"
    returnUrl[@get('provider')]

  createdAt: ->
    @_dateValue('createdAt')

  firstPlan: ->
    _.first(@get('plans'))

  displayName: ->
    @get('name') || capitalize(@firstPlan())
