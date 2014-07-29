environment = require('../config/environment')
Cine = require '../config/cine'
listArchivedStreamFiles = Cine.server_lib('list_archived_stream_files')
EdgecastStream = Cine.server_model('edgecast_stream')

stream = new EdgecastStream(streamName: 'xkMOUbRPZl')

listArchivedStreamFiles stream, (err, files)->
  console.log(err, files)
  process.exit()
