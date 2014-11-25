mongoose = require 'mongoose'

ParsedLogSchema = new mongoose.Schema
  logName:
    type: String
    index: true
    unique: true
  hasStarted:
    type: Boolean
  source:
    type: String
  parseErrors: mongoose.Schema.Types.Mixed
  isComplete:
    type: Boolean
    default: false

ParsedLogSchema.plugin(Cine.server_lib('mongoose_timestamps'))

ParsedLog = mongoose.model 'ParsedLog', ParsedLogSchema

module.exports = ParsedLog
