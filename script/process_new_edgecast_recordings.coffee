environment = require('../config/environment')
Cine.config('connect_to_mongo')

processNewEdgecastRecordings = Cine.server_lib("stream_recordings/process_new_edgecast_recordings")

processNewEdgecastRecordings (err, result)->
  console.log("FINISHED PROCESSING", err, result)
  process.nextTick process.exit
