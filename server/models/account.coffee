mongoose = require 'mongoose'
crypto = require('crypto')
ProvidersAndPlans = Cine.config('providers_and_plans')
_ = require("underscore")

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
  # links to config
  billingProvider:
    type: String
    default: null
  plans:[
    type: String
  ]
  stripeCustomer:
    stripeCustomerId: String
    cards: [StripeCard]
  deletedAt:
    type: Date
  throttledAt:
    type: Date
  throttledReason:
    type: String
  unthrottleable:
    type: Boolean
  herokuId:
    type: String
    index: true
    sparse: true
  engineyardId:
    type: String
    index: true
    sparse: true
  herokuData: mongoose.Schema.Types.Mixed
  appdirectData: mongoose.Schema.Types.Mixed

AccountSchema.plugin(Cine.server_lib('mongoose_timestamps'))

streamLimitForPlan = (planName)->
  switch planName
    when 'free', 'starter', 'sample-addon' then 1
    when 'solo' then 5
    when 'basic', 'pro', 'test' then Infinity
    else throw new Error("Don't know this plan")

aggregatePlanCount = (aggr, planName)->
  aggr + streamLimitForPlan(planName)

AccountSchema.methods.streamLimit = ->
  _.inject @plans, aggregatePlanCount, 0

allProvidersRegex = new RegExp _.keys(ProvidersAndPlans).join('|')

AccountSchema.path('billingProvider').validate ((value)->
  allProvidersRegex.test value
), 'Invalid billing provider'

AccountSchema.path('throttledReason').validate ((value)->
  return true if value == undefined
  /overLimit|cardDeclined/.test value
), 'Invalid throttledReason'

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
