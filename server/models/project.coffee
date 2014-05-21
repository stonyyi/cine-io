mongoose = require 'mongoose'
crypto = require('crypto')

ProjectSchema = new mongoose.Schema
  name:
    type: String
    default: ''
  apiKey:
    type: String
    unique: true
    index: true
  plan:
    type: String

ProjectSchema.plugin(Cine.server_lib('mongoose_timestamps'))

ProjectSchema.pre 'save', (next)->
  return next() if @apiKey
  crypto.randomBytes 16, (ex, buf)=>
    @apiKey = buf.toString('hex')
    next()

ProjectSchema.options.toJSON ||= {}
ProjectSchema.options.toJSON.transform = (doc, ret, options)->
  ret.createdAt = ret.createdAt.toISOString()
  ret

ProjectSchema.path('plan').validate ((value)->
  /free|developer|enterprise/i.test value
), 'Invalid plan'

Project = mongoose.model 'Project', ProjectSchema

module.exports = Project
