console.log('loaded hls app')

express = require('express')
module.exports = app = express()

client = Cine.server_lib('redis_client')
redisKeyForM3U8 = Cine.server_lib('hls/redis_key_for_m3u8')

app.get '/:publicKey/:streamName.m3u8', (req, res)->
  client.get redisKeyForM3U8.withAttributes(req.param('publicKey'), req.param('streamName')), (err, result)->
    return res.status(400).send(400) if err
    return res.status(404).end() unless result
    res.set('Content-Type', 'application/x-mpegurl');
    res.send(result)
