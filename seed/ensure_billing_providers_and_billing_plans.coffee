async = require('async')
BillingProvider = Cine.server_model('billing_provider')
BillingPlan = Cine.server_model('billing_plan')
_ = require('underscore')

providers =
  [
    {name: 'cine.io', url: 'https://www.cine.io'}
    {name: 'heroku', url: 'https://addons.heroku.com/cine'}
  ]

plans =
  [
    # cine
    {name: 'free', providerName: 'cine.io'}
    {name: 'starter', providerName: 'cine.io'}
    {name: 'solo', providerName: 'cine.io'}
    {name: 'basic', providerName: 'cine.io'}
    {name: 'pro', providerName: 'cine.io'}
    # heroku
    {name: 'test', providerName: 'heroku'}
  ]

ensureModel = (Model, query, attributes, callback)->
  Model.findOne query, (err, model)->
    return callback(err) if err
    if model
      model.set(attributes)
    else
      model = new Model(attributes)

    model.save (err, newModel)->
      callback(null, newModel)

createProvider = (attributes, callback)->
  query =
    name: attributes.name
  ensureModel BillingProvider, query, attributes, callback

createProviders = (callback)->
  async.map providers, createProvider, callback

createPlan = (attributes, callback)->
  query =
    name: attributes.name
    _billingProvider: attributes._billingProvider
  ensureModel(BillingPlan, query, attributes, callback)

createPlans = (providers, callback)->
  findProviderFromName = (providerName)->
    _.findWhere providers, name: providerName
  findProviderAndCreatePlan = (attributes, cb)->
    attributes._billingProvider = findProviderFromName(attributes.providerName)._id
    createPlan(attributes, cb)
  async.map plans, findProviderAndCreatePlan, callback

module.exports = (callback)->
  createProviders (err, providers)->
    return callback(err) if err
    # console.log("created providers", providers)
    createPlans providers, (err, plans)->
      return callback(err) if err
      # console.log("created plans", plans)
      callback()
