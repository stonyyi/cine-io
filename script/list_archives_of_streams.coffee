environment = require('../config/environment')
Cine = require '../config/cine'
getStreamRecordings = Cine.server_lib('get_stream_recordings')
EdgecastStream = Cine.server_model('edgecast_stream')

stream = new EdgecastStream(streamName: 'xkMOUbRPZl')

getStreamRecordings stream, (err, files)->
  console.log(err, files)
  process.exit()
