environment = require('../config/environment')
Cine = require '../config/cine'

processFixedRecordings = Cine.server_lib('stream_recordings/process_fixed_recordings.coffee')

processFixedRecordings (err)->
  console.log(err)
  process.nextTick process.exit
