mongo_config = Cine.config('variables/mongo')
mongoose = require('mongoose')
mongoose.connect mongo_config
mongoose.connection.on "open", (ref) ->
  console.log("Connected to mongo at #{mongo_config}")
