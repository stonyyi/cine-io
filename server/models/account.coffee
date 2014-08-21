mongoose = require 'mongoose'
crypto = require('crypto')
BackboneAccount = Cine.model('account')

StripeCard = new mongoose.Schema
  stripeCardId: String
  last4: String
  brand: String
  exp_month: Number
  exp_year: Number
  deletedAt: Date

AccountSchema = new mongoose.Schema
  name:
    type: String
  billingEmail:
    type: String
  masterKey:
    type: String
  # TODO: DEPRECATED
  tempPlan:
    type: String
    required: true
  _billingProvider:
    type: mongoose.Schema.Types.ObjectId
    ref: 'BillingProvider'
  _plans:
    [type: mongoose.Schema.Types.ObjectId, ref: 'BillingPlan']
  stripeCustomer:
    stripeCustomerId: String
    cards: [StripeCard]
  deletedAt:
    type: Date
  herokuId:
    type: String
    index: true
    sparse: true

AccountSchema.plugin(Cine.server_lib('mongoose_timestamps'))

AccountSchema.methods.streamLimit = ->
  switch @tempPlan
    when 'free', 'starter' then 1
    when 'solo' then 5
    when 'startup', 'enterprise' then Infinity
    when 'basic', 'pro', 'test' then Infinity
    else throw new Error("Don't know this plan")

legacyPlans = ['startup', 'enterprise']

herokuSpecificPlans = ['test', 'starter', 'foo']

planRegex = new RegExp BackboneAccount.plans.concat(herokuSpecificPlans).concat(legacyPlans).join('|')
AccountSchema.path('tempPlan').validate ((value)->
  planRegex.test value
), 'Invalid plan'

AccountSchema.pre 'save', (next)->
  return next() if @masterKey
  crypto.randomBytes 32, (ex, buf)=>
    @masterKey = buf.toString('hex')
    next()

AccountSchema.methods.projects = (callback)->
  Project.find().where('_account').equals(@_id).exists('deletedAt', false).sort(createdAt: 1).exec(callback)

Account = mongoose.model 'Account', AccountSchema

module.exports = Account

Project = Cine.server_model('project')
