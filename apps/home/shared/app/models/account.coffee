Base = Cine.model('base')
capitalize = Cine.lib('capitalize')
ProvidersAndPlans  = Cine.require('config/providers_and_plans')
_ = require('underscore')

planIsFree = (product)->
  (plan)->
    ProvidersAndPlans['cine.io'][product].plans[plan].price == 0

module.exports = class Account extends Base
  @id: 'Account'
  url: "/account?masterKey=:masterKey"
  idAttribute: 'masterKey'

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
    return false if _.all @broadcastPlans(), planIsFree('broadcast')
    !@get('stripeCard')?

  updateAccountUrl: ->
    return @get('appdirect').baseUrl if @get('provider') == 'appdirect'
    returnUrl =
      heroku: ProvidersAndPlans['heroku'].broadcast.url
      engineyard: ProvidersAndPlans['engineyard'].broadcast.url
      'cine.io': "https://www.cine.io/account"
    returnUrl[@get('provider')]

  createdAt: ->
    @_dateValue('createdAt')

  broadcastPlans: ->
    plans = @get('productPlans')
    return [] unless plans
    plans.broadcast || []

  firstPlan: ->
    _.first(@broadcastPlans())

  displayName: ->
    @get('name') || capitalize(@firstPlan())
