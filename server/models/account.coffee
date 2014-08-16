mongoose = require 'mongoose'
crypto = require('crypto')

AccountSchema = new mongoose.Schema
  name:
    type: String
  masterEmail:
    type: String
  masterKey:
    type: String
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

AccountSchema.pre 'save', (next)->
  return next() if @masterKey
  crypto.randomBytes 32, (ex, buf)=>
    @masterKey = buf.toString('hex')
    next()

AccountSchema.plugin(Cine.server_lib('mongoose_timestamps'))

Account = mongoose.model 'Account', AccountSchema

module.exports = Account
