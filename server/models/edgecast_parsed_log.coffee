mongoose = require 'mongoose'

EdgecastParsedLogSchema = new mongoose.Schema
  logName:
    type: String
    index: true
    unique: true
  hasStarted:
    type: Boolean
  parseErrors: mongoose.Schema.Types.Mixed
  isComplete:
    type: Boolean
    default: false

EdgecastParsedLogSchema.plugin(Cine.server_lib('mongoose_timestamps'))

EdgecastParsedLog = mongoose.model 'EdgecastParsedLog', EdgecastParsedLogSchema

module.exports = EdgecastParsedLog
