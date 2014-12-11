mongoose = require 'mongoose'
crypto = require('crypto')

HARD_CODED_REALM_SAME_AS_TURN_SERVER = 'cine.io'
COTURN_COLLECTION_NAME = 'turnusers_lt'

TurnUserSchema = new mongoose.Schema
  name:
    type: String
  realm:
    type: String
    default: HARD_CODED_REALM_SAME_AS_TURN_SERVER
  hmackey:
    type: String
  _project:
    type: mongoose.Schema.Types.ObjectId, ref: 'Project'

# TOOD specify joint index used by coturn of realm, name

TurnUserSchema.methods.setHmackey = (password)->
  shasum = crypto.createHash('md5')
  realmString = "#{@name}:#{@realm}:#{password}"
  shasum.update(realmString)
  @hmackey = shasum.digest('hex')

TurnUser = mongoose.model 'TurnUser', TurnUserSchema, COTURN_COLLECTION_NAME

module.exports = TurnUser
