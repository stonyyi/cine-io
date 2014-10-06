environment = require('../config/environment')
Cine = require('../config/cine')

scheduleJob = Cine.server_lib('schedule_job')

scheduleJob 'stream_recordings/process_fixed_recordings', {}, {priority: 1}, (err, response)->
  console.log("scheduled", err, response)
  process.nextTick process.exit
