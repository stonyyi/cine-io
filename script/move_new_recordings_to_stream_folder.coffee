environment = require('../config/environment')
Cine = require '../config/cine'

moveNewRecordingsToStreamFolder = Cine.server_lib('stream_recordings/move_new_recordings_to_stream_folder.coffee')

moveNewRecordingsToStreamFolder (err)->
  console.log(err)
  process.nextTick process.exit
