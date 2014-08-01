mongoose = require 'mongoose'
Schema = mongoose.Schema
findOrCreate = require('mongoose-findorcreate')

EdgecastRecording = new Schema
  name: String
  size: Number
  date: Date

EdgecastRecordingsSchema = new Schema
  _edgecastStream:
    type: mongoose.Schema.Types.ObjectId
    ref: 'EdgecastStream'
  recordings: [EdgecastRecording]

EdgecastRecordingsSchema.plugin(Cine.server_lib('mongoose_timestamps'))

EdgecastRecordingsSchema.plugin(findOrCreate)

EdgecastRecordings = mongoose.model 'EdgecastRecordings', EdgecastRecordingsSchema

module.exports = EdgecastRecordings
