environment = require('../config/environment')

done = (err)->
  if err
    console.log("DONE ERR", err)
    process.exit(1)
  process.exit()

request = require('request')

edgecastConfig = Cine.config('variables/edgecast')
edgecastToken = edgecastConfig.token
edgecastAccount = edgecastConfig.account
# https://my.edgecast.com/uploads/ubers/1/docs/en-US/webhelp/b/RESTAPIHelpCenter/default.htm
hlsEndpointUrl = "https://api.edgecast.com/v2/mcc/customers/#{edgecastAccount}/httpstreaming/livehlshds"

fetchEdgecastUrl = (id, callback)->
  requestOptions =
    url: "#{hlsEndpointUrl}/#{id}"
    headers:
      Authorization: "TOK:#{edgecastToken}"

  request.del requestOptions, (err, response, body)->
    return callback(err) if err
    return callback('not 200') if response.statusCode != 200
    callback()


throw new Error "need HLSID"
fetchEdgecastUrl HLSID, done
