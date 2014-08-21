mongoose = require 'mongoose'

BillingPlanSchema  = new mongoose.Schema
  name:
    type: String
  basePrice:
    type: Number # in USD
  broadcast:
    transferLimit:
      type: Number #in GiB
    transferOverage:
      type: Number #in GiB
    streamLimit:
      type: Number #integer
  cdn:
    storageLimit:
      type: Number #in GiB
    storageOverage:
      type: Number #in GiB
  _billingProvider:
    type: mongoose.Schema.Types.ObjectId
    ref: 'BillingProvider'

BillingPlanSchema.plugin(Cine.server_lib('mongoose_timestamps'))

BillingPlan = mongoose.model 'BillingPlan', BillingPlanSchema

module.exports = BillingPlan
