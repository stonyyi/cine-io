mongoose = require 'mongoose'
_ = require('underscore')

StreamUsageReportSchema = new mongoose.Schema
  _edgecastStream:
    type: mongoose.Schema.Types.ObjectId
    ref: 'EdgecastStream'
    index: true
  # in bytes
  logEntries: [
    # time and date of bandwidth consumption
    entryDate:
      type: Date
    # duration stream played in seconds
    duration:
      type: Number
    bytes:
      type: Number
    kind:
      # either hls or fms
      type: String
  ]

StreamUsageReportSchema.plugin(Cine.server_lib('mongoose_timestamps'))

isSameMonth = (date1, date2)->
  (date1.getFullYear() == date2.getFullYear()) &&
  (date1.getMonth() == date2.getMonth())

# dateToCheck is a full date
StreamUsageReportSchema.methods.bytesForMonth = (dateToCheck)->
  addBytesIfSameMonth = (accum, entry)->
    if isSameMonth(entry.entryDate, dateToCheck) then accum + entry.bytes else accum
  _.reduce @logEntries, addBytesIfSameMonth, 0

StreamUsageReportSchema.methods.totalBytes = ->
  accumEntryBytes = (accum, entry)->
    accum + entry.bytes
  _.reduce @logEntries, accumEntryBytes, 0

StreamUsageReport = mongoose.model 'StreamUsageReport', StreamUsageReportSchema

module.exports = StreamUsageReport
