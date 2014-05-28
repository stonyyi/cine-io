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
  herokuId:
    type: String
  plan:
    type: String
    required: true
  deletedAt:
    type: Date

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
  updateParams = {}
  updateParams[field] = amount
  @collection.findAndModify({ _id: model._id }, [], { $inc: updateParams}, {new: true}, callback)

ProjectSchema.options.toJSON ||= {}
ProjectSchema.options.toJSON.transform = (doc, ret, options)->
  ret.createdAt = ret.createdAt.toISOString()
  ret

ProjectSchema.path('plan').validate ((value)->
  /test|foo|free|developer|enterprise/i.test value
), 'Invalid plan'

Project = mongoose.model 'Project', ProjectSchema

module.exports = Project
