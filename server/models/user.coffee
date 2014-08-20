mongoose = require 'mongoose'
bcrypt = require 'bcrypt'
_ = require 'underscore'
_.str = require 'underscore.string'
Schema = mongoose.Schema
BackboneUser = Cine.model('user')
crypto = require('crypto')

StripeCard = new Schema
  stripeCardId: String
  last4: String
  brand: String
  exp_month: Number
  exp_year: Number
  deletedAt: Date

UserSchema = new Schema
  _accounts:
    [type: mongoose.Schema.Types.ObjectId, ref: 'Account']
  isSiteAdmin:
    type: Boolean
    default: false
  # Email login
  email:
    type: String
    lowercase: true
    trim: true
    index: true
    sparse: true
    unique: true
  # github login
  githubId:
    type: Number
    index: true
    sparse: true
  githubAccessToken:
    type: String
  githubData: mongoose.Schema.Types.Mixed
  herokuId:
    type: String
    index: true
    sparse: true
  hashed_password: String
  password_salt: String
  # Other Info
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
  plan:
    type: String
    required: true
  stripeCustomer:
    stripeCustomerId: String
    cards: [StripeCard]
  deletedAt:
    type: Date
  masterKey:
    type: String

UserSchema.plugin(Cine.server_lib('mongoose_timestamps'))

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
  result = _.pick(json, 'isSiteAdmin', 'createdAt', 'name', 'email', 'masterKey', 'plan', 'githubId', '_accounts')
  result.id = json._id
  result.firstName = @firstName()
  result.lastName = @lastName()
  cards = stripeCards = []
  _.each json.stripeCustomer.cards, (card)->
    return if card.deletedAt?
    newCard = _.pick(card, 'id', 'last4', 'brand', 'exp_month', 'exp_year')
    newCard.id = card._id
    stripeCards.push(newCard)
  result.stripeCard = cards[0]
  result

UserSchema.methods.streamLimit = ->
  switch @plan
    when 'free', 'starter' then 1
    when 'solo' then 5
    when 'startup', 'enterprise', 'test' then Infinity
    else throw new Error("Don't know this plan")

herokuSpecificPlans = ['test', 'starter', 'foo']

planRegex = new RegExp BackboneUser.plans.concat(herokuSpecificPlans).join('|')
UserSchema.path('plan').validate ((value)->
  planRegex.test value
), 'Invalid plan'


UserSchema.pre 'save', (next)->
  return next() if @masterKey
  crypto.randomBytes 32, (ex, buf)=>
    @masterKey = buf.toString('hex')
    next()

User = mongoose.model 'User', UserSchema

module.exports = User
Project = Cine.server_model('project')
