mongoose = require 'mongoose'

EdgecastStreamReportSchema = new mongoose.Schema
  _edgecastStream:
    type: mongoose.Schema.Types.ObjectId
    ref: 'EdgecastStream'
  # in bytes
  totalBandwidth:
    type: Number
    default: 0
  logEntry: [
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

EdgecastStreamReportSchema.plugin(Cine.server_lib('mongoose_timestamps'))

EdgecastStreamReport = mongoose.model 'EdgecastStreamReport', EdgecastStreamReportSchema

module.exports = EdgecastStreamReport
