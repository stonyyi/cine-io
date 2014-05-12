mongoose = require 'mongoose'
_ = require('underscore')

HistoricalSlugSchema = new mongoose.Schema
  _id:
    type: String
  ownerId:
    type: mongoose.Schema.Types.ObjectId
    required: true
  ownerType:
    type: String
    required: true

HistoricalSlugSchema.virtual('owner').set (owner)->
  @ownerId = owner._id
  @ownerType = owner.constructor.modelName
  owner

HistoricalSlugSchema.plugin(Cine.lib('mongoose_timestamps'))

HistoricalSlug = mongoose.model 'HistoricalSlug', HistoricalSlugSchema

module.exports = HistoricalSlug
