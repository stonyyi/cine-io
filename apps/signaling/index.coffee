console.log('loaded hls app')

Base = Cine.require('apps/base')
Cine.config('connect_to_mongo')
module.exports = app = Base.newApp('Cine.io Signaling Server')

app.get '/', (req, res)->
  res.send('cine.io signaling server')

app.get '/chat-example', (req, res)->
  res.sendfile(Cine.path('apps/signaling/chat/chat.html'))
