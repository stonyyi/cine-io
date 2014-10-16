mongoose = require 'mongoose'
crypto = require('crypto')

ProjectSchema = new mongoose.Schema
  name:
    type: String
  publicKey:
    type: String
    unique: true
    index: true
  secretKey:
    type: String
    unique: true
  streamsCount:
    type: Number
    default: 0
  deletedAt:
    type: Date
  throttledAt:
    type: Date
  _account:
    type: mongoose.Schema.Types.ObjectId, ref: 'Account'

ProjectSchema.plugin(Cine.server_lib('mongoose_timestamps'))

ProjectSchema.pre 'save', (next)->
  return next() if @publicKey
  crypto.randomBytes 16, (ex, buf)=>
    @publicKey = buf.toString('hex')
    next()

ProjectSchema.pre 'save', (next)->
  return next() if @secretKey
  crypto.randomBytes 16, (ex, buf)=>
    @secretKey = buf.toString('hex')
    next()

ProjectSchema.statics.increment = (model, field, amount, callback)->
  model[field] += amount
  incrementParams = {}
  incrementParams[field] = amount
  updateParams =
    $inc: incrementParams
    $set:
      updatedAt: new Date
  @collection.findAndModify({ _id: model._id }, [], updateParams, {new: true}, callback)

ProjectSchema.statics.decrement = (model, field, amount, callback)->
  Project.increment(model, field, amount*-1, callback)

ProjectSchema.options.toJSON ||= {}
ProjectSchema.options.toJSON.transform = (doc, ret, options)->
  ret.createdAt = ret.createdAt.toISOString()
  ret


Project = mongoose.model 'Project', ProjectSchema

module.exports = Project
