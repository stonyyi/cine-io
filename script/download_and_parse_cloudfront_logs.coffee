environment = require('../config/environment')
Cine.config('connect_to_mongo')
parseCloudfrontLogs = Cine.server_lib('reporting/download_and_parse_cloudfront_logs')

done = (err)->
  if err
    console.log("DONE ERR", err)
    process.exit(1)
  process.exit()

parseCloudfrontLogs done
