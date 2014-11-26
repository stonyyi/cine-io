mongoose = require 'mongoose'

PeerIdentitySchema = new mongoose.Schema
  _project:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Project'
  identity:
    type: String
    index: true
    required: true

    # spark ids
  currentConnections: [{
    sparkId:
      type: String
    # such as web, android
    # this might have to expand later
    # such as client: Android, might not work if they have a tablet
    # and a mobile phone
    client:
      type: String
  }]

  # I have no idea how to do push notifications
  # to phones that are not currently connected
  # to our signaling server
  # there might need to be way more info here
  mobileConnections: [{
    mobileOS:
      type: String
    identifier:
      type: String
  }]

PeerIdentitySchema.plugin(Cine.server_lib('mongoose_timestamps'))

PeerIdentity = mongoose.model 'PeerIdentity', PeerIdentitySchema
module.exports = PeerIdentity
