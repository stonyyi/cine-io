mongoose = require 'mongoose'
_ = require('underscore')
findOrCreate = require('mongoose-findorcreate')

EmailHistoryRecord = new mongoose.Schema
  kind:
    type: String
  sentAt:
    type: Date

AccountEmailHistorySchema = new mongoose.Schema
  _account:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Account'
    index: true
  history: [EmailHistoryRecord]

AccountEmailHistorySchema.plugin(Cine.server_lib('mongoose_timestamps'))
AccountEmailHistorySchema.plugin(findOrCreate)

isSameMonth = (date1, date2)->
  (date1.getFullYear() == date2.getFullYear()) &&
  (date1.getMonth() == date2.getMonth())

AccountEmailHistorySchema.methods.recordForMonth = (dateToCheck, kind)->
  trueIfSameMonth = (entry)->
    entry.kind == kind && isSameMonth(entry.sentAt, dateToCheck)
  _.find @history, trueIfSameMonth

AccountEmailHistorySchema.methods.findKind = (kind)->
  _.findWhere @history, kind: kind

AccountEmailHistory = mongoose.model 'AccountEmailHistory', AccountEmailHistorySchema

module.exports = AccountEmailHistory
