mongoose = require 'mongoose'
crypto = require('crypto')
findOrCreate = require('mongoose-findorcreate')

COTURN_COLLECTION_NAME = 'realms'

RealmSchema = new mongoose.Schema
  realm:
    type: String

RealmSchema.plugin(findOrCreate)

Realm = mongoose.model 'Realm', RealmSchema, COTURN_COLLECTION_NAME
module.exports = Realm
module.exports.HARD_CODED_REALM_SAME_AS_TURN_SERVER = 'cine.io'
