environment = require('../config/environment')
Cine = require '../config/cine'

fixStreamCodec = Cine.server_lib('stream_recordings/fix_edgecast_codecs_on_new_stream_recordings')

fixStreamCodec (err)->
  console.log(err)
  process.nextTick process.exit
