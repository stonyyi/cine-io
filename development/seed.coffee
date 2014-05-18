environment = require('../config/environment')
return console.error('not development') if environment != 'development'


mongoose = require('mongoose')
async = require 'async'
_ = require 'underscore'

mongooseResultToUsable = (results)->
  _.map results, (result)->
    result[0]

seed = (callback)->
  console.log('seeding')
  createUsers = require('./seed/user_seed')
  createProjects = require('./seed/project_seed')
  createStreams = require('./seed/stream_seed')

  async.parallel [createUsers], (err, results)->
    console.log('first pass', err)
    users = mongooseResultToUsable(results[0])
    createProjects users, (err, results)->
      console.log('second pass', err)
      projects = results
      createStreams projects, (err, results)->
        console.log('third pass', err)
        console.log('done')
        return process.exit(1) if err
        return process.exit()

resetMongo = (done)->
  if mongoose.connection._readyState == 1
    console.log('ready')
    return mongoose.connection.db.dropDatabase done
  mongoose.connection.on "open", (ref) ->
    console.log('ready2')
    mongoose.connection.db.dropDatabase done

resetMongo(seed)
