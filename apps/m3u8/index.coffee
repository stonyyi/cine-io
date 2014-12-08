console.log('loaded hls app')
Base = Cine.require('apps/base')

fs = require('fs')
module.exports = app = Base.app('Cine.io hls')

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

fileName = __dirname + "/crossdomain.xml"
app.get '/crossdomain.xml', (req, res)->
  readStream = fs.createReadStream(fileName)
  res.set('Content-Type', 'text/x-cross-domain-policy')
  readStream.pipe(res)
