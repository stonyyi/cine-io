User = Cine.server_model 'user'
async = require 'async'
_ = require 'underscore'

adminMaker = (name, callback)->
  user = new User(email: "#{name}@cine.io", name: name)
  user.assignHashedPasswordAndSalt 'cine', (err)->
    return callback(err) if err
    user.save(callback)

module.exports = (callback)->
  console.log('creating users')
  async.parallel [(callback) ->
    adminMaker('thomas', callback)
  , (callback) ->
    adminMaker('jeffrey', callback)
  ], callback
