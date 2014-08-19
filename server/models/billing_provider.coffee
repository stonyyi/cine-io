mongoose = require 'mongoose'

BillingProviderSchema  = new mongoose.Schema
  name:
    type: String
  url:
    type: String

BillingProviderSchema.plugin(Cine.server_lib('mongoose_timestamps'))

BillingProvider = mongoose.model 'BillingProvider', BillingProviderSchema

module.exports = BillingProvider
