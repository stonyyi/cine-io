environment = require('../config/environment')
refreshEdgecastStreams = Cine.server_lib('refresh_edgecast_streams')

done = (err)->
  if err
    console.log("DONE ERR", err)
    process.exit(1)
  process.exit()

refreshEdgecastStreams done
