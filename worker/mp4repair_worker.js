require('coffee-script/register')
Cine = require('./config/cine_server')
repairFile = Cine.server_lib("stream_recordings/transcode_recording")

repairFile('wrongaspect.mp4', 'rightaspect.mp4', function() {
  console.log("DONE!")
})
