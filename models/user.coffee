mongoose = require 'mongoose'
bcrypt = require 'bcrypt'
_ = require 'underscore'
_.str = require 'underscore.string'
Schema = mongoose.Schema

# special permission has objectName of 'site'
Permission = new Schema
  objectId: mongoose.Schema.Types.ObjectId
  objectName: String

UserSchema = new Schema
  # Email login
  email:
    type: String
    lowercase: true
    trim: true
    required: true
  hashed_password: String
  password_salt: String
  # Other Info
  permissions: [Permission]
  _referringUser:
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
  generation:
    type: Number
    default: 0
  name:
    type: String
    default: ''
    trim: true

UserSchema.plugin(SS.lib('mongoose_timestamps'))

generateSaltAndHashForPassword = (cleartext_password, callback)->
  bcrypt.genSalt 10, (error, salt)->
    return callback(error.message) if error
    generateHashForPasswordAndSalt(cleartext_password, salt, callback)

generateHashForPasswordAndSalt = (cleartext_password, salt, callback)->
  bcrypt.hash cleartext_password, salt, (error, hash)->
    return callback(error.message) if error
    callback(null, hash, salt)

UserSchema.methods.firstName = ->
  @name.split(' ')[0]

UserSchema.methods.lastName = ->
  parts = @name.split(' ')
  parts.slice(1, parts.length).join(' ')

UserSchema.methods.isCorrectPassword = (cleartext_password, callback)->
  generateHashForPasswordAndSalt cleartext_password, @password_salt, (err, hash, salt)=>
    return callback(err) if err
    if @hashed_password == hash then callback(null) else callback('Incorrect password')

UserSchema.methods.assignHashedPasswordAndSalt = (cleartext_password, callback)->
  generateSaltAndHashForPassword cleartext_password, (err, hash, salt)=>
    return callback(err) if err
    @hashed_password = hash
    @password_salt = salt
    callback(null)

UserSchema.methods.simpleCurrentUserJSON = ->
  json = @toJSON()
  result = _.pick(json, '_id', 'createdAt', 'name', 'email', 'permissions')
  result.firstName = @firstName()
  result.lastName = @lastName()
  result

UserSchema.methods.toInternalApiJSON = ->
  json = @toJSON()
  _.omit(json, '__v', 'hashed_password', 'password_salt')

User = mongoose.model 'User', UserSchema

module.exports = User
