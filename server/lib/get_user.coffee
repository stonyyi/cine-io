User = Cine.server_model('user')

module.exports = (params, callback)->
  userId = params.sessionUserId
  return callback('not logged in', null, status: 401) unless userId
  User.findById userId, (err, user)->
    return callback(err, null, status: 401) if err
    return callback('user not found', null, status: 404) if !user
    callback(null, user)
