console.log('loaded rtc transmuxer')

Base = Cine.require('apps/base')
Cine.config('connect_to_mongo')
module.exports = app = Base.app("rtc transmuxer")

app.get '/', (req, res)->
  res.send("I am the rtc_transmuxer")
