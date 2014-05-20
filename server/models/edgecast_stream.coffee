mongoose = require 'mongoose'

EdgecastStreamSchema = new mongoose.Schema
  _project:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Project'
  instanceName:
    type: String
  eventName:
    type: String
  streamName:
    type: String
  streamKey:
    type: String
  expiration:
    type: Date
  edgecastId:
    type: Number
  deletedAt:
    type: Date

EdgecastStreamSchema.statics.nextAvailable = (callback)->
  query =
    _project: {$exists: false}
    deletedAt: {$exists: false}
  @findOne(query).sort(createdAt: 1).exec(callback)

EdgecastStreamSchema.plugin(Cine.server_lib('mongoose_timestamps'))

EdgecastStream = mongoose.model 'EdgecastStream', EdgecastStreamSchema

module.exports = EdgecastStream
