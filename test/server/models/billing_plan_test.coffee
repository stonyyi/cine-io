BillingPlan = Cine.server_model('billing_plan')
_ = require('underscore')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'BillingPlan', ->
  modelTimestamps(BillingPlan)
