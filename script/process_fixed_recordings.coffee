environment = require('../config/environment')
Cine.config('connect_to_mongo')

processFixedRecordings = Cine.server_lib('stream_recordings/process_fixed_recordings.coffee')

processFixedRecordings (err)->
  console.log(err)
  process.nextTick process.exit
