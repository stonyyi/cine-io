PeerIdentity = Cine.server_model('peer_identity')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'PeerIdentity', ->
  modelTimestamps PeerIdentity, identity: 'thomas'
