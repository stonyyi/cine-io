mongoose = require 'mongoose'
crypto = require('crypto')

PasswordChangeRequestSchema = new mongoose.Schema
  identifier:
    type: String
    unique: true
  _user:
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'

PasswordChangeRequestSchema.pre 'save', (next)->
  return next() if @identifier
  crypto.randomBytes 24, (ex, buf)=>
    @identifier = buf.toString('hex')
    next()

PasswordChangeRequestSchema.plugin(SS.lib('mongoose_timestamps'))

PasswordChangeRequest = mongoose.model 'PasswordChangeRequest', PasswordChangeRequestSchema

module.exports = PasswordChangeRequest
