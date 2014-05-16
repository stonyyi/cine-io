mongoose = require 'mongoose'
crypto = require('crypto')

RememberMeTokenSchema = new mongoose.Schema
  token:
    type: String
    unique: true
  _user:
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'

RememberMeTokenSchema.pre 'save', (next)->
  return next() if @token
  crypto.randomBytes 32, (ex, buf)=>
    @token = buf.toString('hex')
    next()

RememberMeTokenSchema.plugin(Cine.server_lib('mongoose_timestamps'))

RememberMeToken = mongoose.model 'RememberMeToken', RememberMeTokenSchema

module.exports = RememberMeToken
