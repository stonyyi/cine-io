environment = require('../config/environment')
parseEdgecastLogs = Cine.server_lib('reporting/download_and_parse_edgecast_logs')

done = (err)->
  if err
    console.log("DONE ERR", err)
    process.exit(1)
  process.exit()

parseEdgecastLogs done
