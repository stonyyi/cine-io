BillingProvider = Cine.server_model('billing_provider')
_ = require('underscore')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'BillingProvider', ->
  modelTimestamps(BillingProvider)
