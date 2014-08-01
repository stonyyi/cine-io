EdgecastRecordings = Cine.server_model('edgecast_recordings')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'EdgecastRecordings', ->
  modelTimestamps EdgecastRecordings, name: 'some name'
