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

  isCine: ->
    @get('provider') == 'cine.io'

  @include Cine.lib('date_value')

  isDisabled: ->
    @get('isDisabled')

  needsCreditCard: ->
    return false unless @isCine()
    return false if @get('cannotBeDisabled')
    return false if _.all(@broadcastPlans(), planIsFree('broadcast')) && _.all(@peerPlans(), planIsFree('peer'))
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

  peerPlans: ->
    plans = @get('productPlans')
    return [] unless plans
    plans.peer || []

  firstPlan: ->
    _.first(@broadcastPlans())

  displayName: ->
    @get('name') || capitalize(@firstPlan())
