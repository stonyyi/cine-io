environment = require('../config/environment')
Cine = require '../config/cine'

processNewStreamRecordings = Cine.server_lib('stream_recordings/process_new_stream_recordings.coffee')

processNewStreamRecordings (err)->
  console.log(err)
  process.nextTick process.exit
