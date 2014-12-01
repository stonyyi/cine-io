mongoose = require 'mongoose'
_ = require('underscore')

BillingHistoryRecord = new mongoose.Schema
  billingDate:
    type: Date
  billedAt:
    type: Date
  paid:
    type: Boolean
  notCharged:
    type: Boolean
  mandrillEmailId:
    type: String
  stripeChargeId:
    type: String
  chargeError:
    type: String
  accountPlans:
    [type: String]
  details:
    type: mongoose.Schema.Types.Mixed

AccountBillingHistorySchema = new mongoose.Schema
  _account:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Account'
    index: true
  history: [BillingHistoryRecord]

AccountBillingHistorySchema.plugin(Cine.server_lib('mongoose_timestamps'))

isSameMonth = (date1, date2)->
  (date1.getFullYear() == date2.getFullYear()) &&
  (date1.getMonth() == date2.getMonth())

AccountBillingHistorySchema.methods.billingRecordForMonth = (dateToCheck)->
  trueIfSameMonth = (entry)->
    isSameMonth(entry.billingDate, dateToCheck)
  _.find @history, trueIfSameMonth

AccountBillingHistorySchema.methods.hasBilledForMonth = (dateToCheck)->
  record = @billingRecordForMonth(dateToCheck)
  return false unless record
  record = record.toObject()
  return record.notCharged if _.has(record, 'notCharged')
  return record.paid if _.has(record, 'paid')
  return false

AccountBillingHistory = mongoose.model 'AccountBillingHistory', AccountBillingHistorySchema

module.exports = AccountBillingHistory
