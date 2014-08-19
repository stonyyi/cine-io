mongoose = require 'mongoose'

BillingPlanSchema  = new mongoose.Schema
  name:
    type: String
  basePrice:
    type: Number # in USD
  broadcast:
    transferLimit:
      type: Number #in GB
    transferOverage:
      type: Number #in GB
    streamLimit:
      type: Number #integer
  cdn:
    storageLimit:
      type: Number #in GB
    storageOverage:
      type: Number #in GB
  _billingProvider:
    type: mongoose.Schema.Types.ObjectId
    ref: 'BillingProvider'

BillingPlanSchema.plugin(Cine.server_lib('mongoose_timestamps'))

BillingPlan = mongoose.model 'BillingPlan', BillingPlanSchema

module.exports = BillingPlan
