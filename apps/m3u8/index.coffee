console.log('loaded hls app')

Base = Cine.require('apps/base')
module.exports = app = Base.newApp('Cine.io hls')

Cine.middleware('health_check', app)
Cine.middleware('deploy_info', app)

client = Cine.server_lib('redis_client')
redisKeyForM3U8 = Cine.server_lib('hls/redis_key_for_m3u8')

respond = (req, res)->
  client.get redisKeyForM3U8.withAttribute(req.param('streamName', res)), (err, result)->
    return res.status(400).send(err) if err
    return res.status(404).end() unless result
    res.set('Content-Type', 'application/x-mpegurl')
    res.send(result)

app.get '/', (req, res)->
  res.send("I am the cine.io m3u8 server")

app.get '/:publicKey/:streamName.m3u8', respond

app.get '/:streamName.m3u8', respond
