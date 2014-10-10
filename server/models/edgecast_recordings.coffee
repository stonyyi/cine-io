mongoose = require 'mongoose'
Schema = mongoose.Schema
findOrCreate = require('mongoose-findorcreate')
_ = require('underscore')

EdgecastRecording = new Schema
  name: String
  size: Number
  date: Date
  deletedAt: Date
  vodBookkeeperTest: Boolean

EdgecastRecordingsSchema = new Schema
  _edgecastStream:
    type: mongoose.Schema.Types.ObjectId
    ref: 'EdgecastStream'
  recordings: [EdgecastRecording]

EdgecastRecordingsSchema.plugin(Cine.server_lib('mongoose_timestamps'))

EdgecastRecordingsSchema.plugin(findOrCreate)


EdgecastRecordingsSchema.methods.totalBytes = ->
  accumEntryBytes = (accum, entry)->
    accum + entry.size

  _.chain(@recordings)
    .where(deletedAt: undefined)
    .where(vodBookkeeperTest: undefined)
    .reduce(accumEntryBytes, 0)
    .value()

EdgecastRecordings = mongoose.model 'EdgecastRecordings', EdgecastRecordingsSchema

module.exports = EdgecastRecordings
