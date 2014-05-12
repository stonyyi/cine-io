mongoose = require 'mongoose'

EdgecastStreamSchema = new mongoose.Schema
  _organization:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Organization'
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
    _organization: {$exists: false}
  @findOne(query).sort(createdAt: -1).exec(callback)

EdgecastStreamSchema.plugin(Cine.lib('mongoose_timestamps'))

EdgecastStream = mongoose.model 'EdgecastStream', EdgecastStreamSchema

module.exports = EdgecastStream
